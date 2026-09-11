import { createPinia, setActivePinia } from "pinia"
import { registerEndpoint } from "@nuxt/test-utils/runtime"
import { beforeEach, describe, expect, it } from "vitest"
import { useNotificationsStore } from "~/stores/notifications"

registerEndpoint("/api/v1/notifications", {
  method: "GET",
  handler: () => ({
    data: [
      { id: 1, title: "Aviso 1", body: "Corpo 1", category: "info", read: false, read_at: null, created_at: "2026-01-01T00:00:00Z" },
      { id: 2, title: "Aviso 2", body: "Corpo 2", category: "warning", read: false, read_at: null, created_at: "2026-01-02T00:00:00Z" },
    ],
    meta: { page: 1, pages: 1, count: 2, per_page: 8 },
  }),
})

registerEndpoint("/api/v1/notifications/1/read", {
  method: "PATCH",
  handler: () => ({ data: { id: 1, title: "Aviso 1", read: true } }),
})

registerEndpoint("/api/v1/notifications/read_all", {
  method: "PATCH",
  handler: () => ({}),
})

describe("useNotificationsStore", () => {
  beforeEach(() => setActivePinia(createPinia()))

  it("fetchUnread carrega as notificações recentes e o total não lido", async () => {
    const store = useNotificationsStore()

    await store.fetchUnread()

    expect(store.loaded).toBe(true)
    expect(store.unreadCount).toBe(2)
    expect(store.recent).toHaveLength(2)
    expect(store.recent[0].title).toBe("Aviso 1")
  })

  it("markRead remove a notificação da lista e decrementa a contagem", async () => {
    const store = useNotificationsStore()
    await store.fetchUnread()

    await store.markRead(1)

    expect(store.recent.find((n) => n.id === 1)).toBeUndefined()
    expect(store.recent).toHaveLength(1)
    expect(store.unreadCount).toBe(1)
  })

  it("markAllRead esvazia a lista e zera a contagem", async () => {
    const store = useNotificationsStore()
    await store.fetchUnread()

    await store.markAllRead()

    expect(store.recent).toHaveLength(0)
    expect(store.unreadCount).toBe(0)
  })

  it("unreadCount nunca fica negativo", async () => {
    const store = useNotificationsStore()
    store.unreadCount = 0
    store.recent = []

    await store.markRead(1)

    expect(store.unreadCount).toBe(0)
  })
})
