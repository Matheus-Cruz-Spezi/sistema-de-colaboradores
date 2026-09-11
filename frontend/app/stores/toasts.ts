import { defineStore } from "pinia"

export interface Toast {
  id: number
  title: string
  body: string | null
  category: "info" | "success" | "warning" | "alert" | string
}

let nextId = 1

const DEFAULT_TIMEOUT = 6000

export const useToastsStore = defineStore("toasts", {
  state: () => ({
    items: [] as Toast[],
  }),

  actions: {
    // Aparece como banner na tela e some sozinho depois de `timeout` ms
    // (0 = fica até o usuário fechar).
    push(toast: Omit<Toast, "id">, timeout = DEFAULT_TIMEOUT) {
      const id = nextId++
      this.items.push({ id, ...toast })

      if (import.meta.client && timeout > 0) {
        setTimeout(() => this.dismiss(id), timeout)
      }

      return id
    },

    dismiss(id: number) {
      this.items = this.items.filter((t) => t.id !== id)
    },
  },
})
