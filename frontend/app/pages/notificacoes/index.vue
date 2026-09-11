<script setup lang="ts">
import type { Notification } from "~/stores/notifications"

interface Meta { page: number; pages: number; count: number; per_page: number }

const api = useApi()
const store = useNotificationsStore()

const onlyUnread = ref(false)
const page = ref(1)
watch(onlyUnread, () => (page.value = 1))

const { data, pending, error, refresh } = useAsyncData(
  "notifications-list",
  () =>
    api<{ data: Notification[]; meta: Meta }>("/api/v1/notifications", {
      query: { unread: onlyUnread.value ? "true" : undefined, page: page.value, per_page: 15 },
    }),
  { lazy: true, watch: [onlyUnread, page] },
)

const rows = computed(() => data.value?.data ?? [])
const meta = computed(() => data.value?.meta)

async function markRead(n: Notification) {
  if (n.read) return
  await api(`/api/v1/notifications/${n.id}/read`, { method: "PATCH" })
  await Promise.all([refresh(), store.fetchUnread()])
}

async function markAllRead() {
  await api("/api/v1/notifications/read_all", { method: "PATCH" })
  await Promise.all([refresh(), store.fetchUnread()])
}

async function remove(n: Notification) {
  await api(`/api/v1/notifications/${n.id}`, { method: "DELETE" })
  await Promise.all([refresh(), store.fetchUnread()])
}
</script>

<template>
  <div class="stack">
    <div class="row" style="justify-content: space-between">
      <div>
        <h1>Notificações</h1>
        <p class="muted">Avisos e alterações relevantes para você</p>
      </div>
      <button class="btn btn-ghost btn-sm" type="button" @click="markAllRead">Marcar todas como lidas</button>
    </div>

    <label class="filter-check">
      <input v-model="onlyUnread" type="checkbox" />
      Mostrar somente não lidas
    </label>

    <div class="card list-card">
      <p v-if="pending" class="muted pad">Carregando…</p>
      <p v-else-if="error" class="alert alert-danger">Não foi possível carregar as notificações.</p>
      <p v-else-if="rows.length === 0" class="muted pad">Nenhuma notificação por aqui.</p>

      <ul v-else class="n-list">
        <li v-for="n in rows" :key="n.id" :class="{ unread: !n.read }">
          <span class="n-icon">{{ notificationIcon(n.category) }}</span>

          <div class="n-body">
            <div class="n-title-row">
              <strong>{{ n.title }}</strong>
              <span v-if="!n.read" class="dot" aria-label="não lida" />
            </div>
            <p v-if="n.body" class="muted n-text">{{ n.body }}</p>
            <span class="muted n-time">{{ formatDateTime(n.created_at) }} · {{ timeAgo(n.created_at) }}</span>
          </div>

          <div class="n-actions">
            <button v-if="!n.read" type="button" class="btn btn-ghost btn-sm" @click="markRead(n)">Marcar como lida</button>
            <button type="button" class="btn btn-ghost btn-sm btn-danger-ghost" @click="remove(n)">Excluir</button>
          </div>
        </li>
      </ul>

      <div v-if="meta && meta.pages > 1" class="pager">
        <button class="btn btn-ghost btn-sm" :disabled="page <= 1" @click="page--">Anterior</button>
        <span class="muted">Página {{ meta.page }} de {{ meta.pages }} · {{ meta.count }} no total</span>
        <button class="btn btn-ghost btn-sm" :disabled="page >= meta.pages" @click="page++">Próxima</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
h1 { font-size: 1.4rem; }
.btn-sm { padding: 6px 12px; font-size: .85rem; }
.filter-check { display: flex; align-items: center; gap: 8px; font-size: .9rem; color: var(--text-muted); }
.list-card { padding: 0; overflow: hidden; }
.pad { padding: 20px; }
.alert { margin: 16px; }

.n-list { list-style: none; margin: 0; padding: 0; }
.n-list li { display: flex; gap: 12px; padding: 14px 16px; border-bottom: 1px solid var(--border); align-items: flex-start; flex-wrap: wrap; }
.n-list li:last-child { border-bottom: 0; }
.n-list li.unread { background: var(--primary-soft); }
.n-icon { font-size: 1.1rem; line-height: 1.5; }
.n-body { flex: 1; min-width: 200px; display: flex; flex-direction: column; gap: 2px; }
.n-title-row { display: flex; align-items: center; gap: 8px; }
.dot { width: 8px; height: 8px; border-radius: 50%; background: var(--primary); flex-shrink: 0; }
.n-text { margin: 0; font-size: .9rem; }
.n-time { font-size: .78rem; }
.n-actions { display: flex; gap: 8px; align-items: center; flex-shrink: 0; }
.btn-danger-ghost:hover { color: var(--danger); border-color: var(--danger); }
.pager { display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 14px 16px; border-top: 1px solid var(--border); flex-wrap: wrap; }
</style>
