import { defineStore } from "pinia"
import type { Notification } from "./notifications"

interface User {
  id: number
  email: string
  role: "admin" | "manager" | "employee" | string
  created_at?: string
}

const TOKEN_KEY = "rh.token"
const USER_KEY = "rh.user"

function readStorage<T>(key: string): T | null {
  try {
    const raw = localStorage.getItem(key)
    return raw ? (JSON.parse(raw) as T) : null
  } catch {
    return null
  }
}

export const useAuthStore = defineStore("auth", {
  state: () => ({
    token: null as string | null,
    user: null as User | null,
    ready: false,
  }),

  getters: {
    isAuthenticated: (s) => !!s.token,
    isAdmin: (s) => s.user?.role === "admin",
    isManager: (s) => s.user?.role === "manager",
    isColaborador: (s) => s.user?.role === "employee",
    canSeeDashboard: (s) => s.user?.role === "admin" || s.user?.role === "manager",
    // Admin e gestor podem ver/selecionar a lista de perfis (só o admin edita).
    canBrowseProfiles: (s) => s.user?.role === "admin" || s.user?.role === "manager",
    roleLabel: (s) => ({ admin: "Administrador", manager: "Gestor", employee: "Colaborador" }[s.user?.role ?? ""] ?? s.user?.role ?? ""),
    authHeader: (s) => (s.token ? { Authorization: `Bearer ${s.token}` } : {}),
  },

  actions: {
    // Restaura a sessão do localStorage (chamado por um plugin no boot).
    hydrate() {
      try {
        this.token = localStorage.getItem(TOKEN_KEY)
      } catch {
        this.token = null
      }
      this.user = readStorage<User>(USER_KEY)
      this.ready = true
    },

    persist() {
      try {
        if (this.token) localStorage.setItem(TOKEN_KEY, this.token)
        else localStorage.removeItem(TOKEN_KEY)
        if (this.user) localStorage.setItem(USER_KEY, JSON.stringify(this.user))
        else localStorage.removeItem(USER_KEY)
      } catch {
        /* modo privado / storage bloqueado */
      }
    },

    async login(email: string, password: string) {
      const data = await $fetch<{ user: User; token: string; notification?: Notification }>("/api/v1/login", {
        method: "POST",
        body: { email, password },
      })
      this.token = data.token
      this.user = data.user
      this.persist()

      // O backend cria uma notificação de boas-vindas a cada login — mostra
      // na hora como toast e já deixa marcada como não lida no sininho, pra
      // confirmar visualmente que o sistema de notificações está no ar.
      if (data.notification) {
        useNotificationsStore().addLocal(data.notification)
        useToastsStore().push({
          title: data.notification.title,
          body: data.notification.body,
          category: data.notification.category,
        })
      }
    },

    logout() {
      if (this.token) {
        $fetch("/api/v1/logout", { method: "DELETE", headers: this.authHeader }).catch(() => {})
      }
      this.token = null
      this.user = null
      this.persist()
    },

    setUser(user: User) {
      this.user = user
      this.persist()
    },
  },
})
