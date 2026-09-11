import { defineStore } from "pinia"

export interface Notification {
  id: number
  title: string
  body: string | null
  category: "info" | "success" | "warning" | "alert" | string
  read: boolean
  read_at: string | null
  created_at: string
}

interface Meta {
  page: number
  pages: number
  count: number
  per_page: number
}

const RECENT_LIMIT = 8

export const useNotificationsStore = defineStore("notifications", {
  state: () => ({
    recent: [] as Notification[],
    unreadCount: 0,
    loaded: false,
  }),

  actions: {
    // Usado pelo sininho no topo: as N mais recentes não lidas + o total.
    async fetchUnread() {
      const api = useApi()
      const res = await api<{ data: Notification[]; meta: Meta }>("/api/v1/notifications", {
        query: { unread: "true", per_page: RECENT_LIMIT },
      })
      this.recent = res.data
      this.unreadCount = res.meta.count
      this.loaded = true
    },

    async markRead(id: number) {
      const api = useApi()
      await api(`/api/v1/notifications/${id}/read`, { method: "PATCH" })
      this.recent = this.recent.filter((n) => n.id !== id)
      this.unreadCount = Math.max(0, this.unreadCount - 1)
    },

    async markAllRead() {
      const api = useApi()
      await api("/api/v1/notifications/read_all", { method: "PATCH" })
      this.recent = []
      this.unreadCount = 0
    },
  },
})
