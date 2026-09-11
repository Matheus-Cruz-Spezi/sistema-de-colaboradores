import { createPinia, setActivePinia } from "pinia"
import { registerEndpoint } from "@nuxt/test-utils/runtime"
import { beforeEach, describe, expect, it } from "vitest"
import { useAuthStore } from "~/stores/auth"

registerEndpoint("/api/v1/login", {
  method: "POST",
  handler: () => ({
    user: { id: 1, email: "admin@empresa.com", role: "admin" },
    token: "fake-jwt-token",
  }),
})

registerEndpoint("/api/v1/logout", {
  method: "DELETE",
  handler: () => ({}),
})

describe("useAuthStore", () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    localStorage.clear()
  })

  it("login guarda o token e o usuário, e persiste no localStorage", async () => {
    const auth = useAuthStore()

    await auth.login("admin@empresa.com", "password123")

    expect(auth.token).toBe("fake-jwt-token")
    expect(auth.user?.email).toBe("admin@empresa.com")
    expect(auth.isAuthenticated).toBe(true)
    expect(auth.isAdmin).toBe(true)
    expect(localStorage.getItem("rh.token")).toBe("fake-jwt-token")
    expect(JSON.parse(localStorage.getItem("rh.user")!).email).toBe("admin@empresa.com")
  })

  it("hydrate recupera uma sessão salva no localStorage", () => {
    localStorage.setItem("rh.token", "outro-token")
    localStorage.setItem("rh.user", JSON.stringify({ id: 2, email: "gestor@empresa.com", role: "manager" }))

    const auth = useAuthStore()
    auth.hydrate()

    expect(auth.token).toBe("outro-token")
    expect(auth.isManager).toBe(true)
    expect(auth.isAdmin).toBe(false)
    expect(auth.ready).toBe(true)
  })

  it("hydrate não quebra quando não há sessão salva", () => {
    const auth = useAuthStore()
    auth.hydrate()

    expect(auth.token).toBeNull()
    expect(auth.user).toBeNull()
    expect(auth.isAuthenticated).toBe(false)
  })

  it("logout limpa o estado em memória e o localStorage", async () => {
    const auth = useAuthStore()
    await auth.login("admin@empresa.com", "password123")

    auth.logout()

    expect(auth.token).toBeNull()
    expect(auth.user).toBeNull()
    expect(auth.isAuthenticated).toBe(false)
    expect(localStorage.getItem("rh.token")).toBeNull()
    expect(localStorage.getItem("rh.user")).toBeNull()
  })

  it("roleLabel traduz o papel do usuário para português", () => {
    const auth = useAuthStore()
    auth.setUser({ id: 3, email: "colab@empresa.com", role: "employee" })

    expect(auth.roleLabel).toBe("Colaborador")
    expect(auth.canSeeDashboard).toBe(false)
    expect(auth.canBrowseProfiles).toBe(false)
  })

  it("authHeader só existe quando há token", () => {
    const auth = useAuthStore()
    expect(auth.authHeader).toEqual({})

    auth.token = "abc"
    expect(auth.authHeader).toEqual({ Authorization: "Bearer abc" })
  })
})
