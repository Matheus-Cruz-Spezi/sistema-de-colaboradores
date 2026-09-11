<script setup lang="ts">
const store = useNotificationsStore()
const rootEl = ref<HTMLElement | null>(null)
const open = ref(false)

onMounted(() => {
  store.fetchUnread().catch(() => {})
  document.addEventListener("click", onClickOutside)
})
onUnmounted(() => document.removeEventListener("click", onClickOutside))

function onClickOutside(event: MouseEvent) {
  if (rootEl.value && !rootEl.value.contains(event.target as Node)) open.value = false
}

function toggle() {
  open.value = !open.value
  if (open.value) store.fetchUnread().catch(() => {})
}

async function readOne(id: number) {
  await store.markRead(id).catch(() => {})
}

async function readAll() {
  await store.markAllRead().catch(() => {})
}
</script>

<template>
  <div ref="rootEl" class="bell-wrap">
    <button
      type="button"
      class="bell-btn"
      :class="{ ringing: store.unreadCount > 0 }"
      :aria-expanded="open"
      aria-label="Notificações"
      @click="toggle"
    >
      🔔
      <span v-if="store.unreadCount > 0" class="bell-badge">{{ store.unreadCount > 9 ? "9+" : store.unreadCount }}</span>
    </button>

    <div v-if="open" class="bell-panel">
      <div class="bell-head">
        <strong>Notificações</strong>
        <button v-if="store.recent.length" type="button" class="link-btn" @click="readAll">Marcar todas como lidas</button>
      </div>

      <p v-if="!store.loaded" class="muted pad">Carregando…</p>
      <p v-else-if="store.recent.length === 0" class="muted pad">Nenhuma notificação nova. 🎉</p>

      <ul v-else class="bell-list">
        <li v-for="n in store.recent" :key="n.id">
          <button type="button" class="bell-item" @click="readOne(n.id)">
            <span class="bell-icon">{{ notificationIcon(n.category) }}</span>
            <span class="bell-item-body">
              <strong>{{ n.title }}</strong>
              <span v-if="n.body" class="muted bell-snippet">{{ n.body }}</span>
              <span class="muted bell-time">{{ timeAgo(n.created_at) }}</span>
            </span>
          </button>
        </li>
      </ul>

      <NuxtLink to="/notificacoes" class="bell-footer" @click="open = false">Ver todas as notificações</NuxtLink>
    </div>
  </div>
</template>

<style scoped>
.bell-wrap { position: relative; }
.bell-btn {
  position: relative;
  background: transparent;
  border: 1px solid var(--border);
  border-radius: 8px;
  width: 36px; height: 36px;
  font-size: 1rem;
  cursor: pointer;
  display: grid;
  place-items: center;
}
.bell-btn:hover { background: var(--surface-2); }
.bell-btn.ringing { animation: bell-ring 3.2s ease-in-out infinite; }
.bell-badge {
  position: absolute;
  top: -6px; right: -6px;
  background: var(--danger);
  color: #fff;
  font-size: .68rem;
  font-weight: 700;
  line-height: 1;
  padding: 2px 5px;
  border-radius: 999px;
  min-width: 18px;
  text-align: center;
}

.bell-panel {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  width: min(340px, 90vw);
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  overflow: hidden;
  z-index: 20;
}
.bell-head { display: flex; align-items: center; justify-content: space-between; gap: 8px; padding: 12px 14px; border-bottom: 1px solid var(--border); }
.link-btn { background: none; border: 0; color: var(--primary); font: inherit; font-size: .8rem; font-weight: 600; cursor: pointer; padding: 0; }
.pad { padding: 18px 14px; margin: 0; }

.bell-list { list-style: none; margin: 0; padding: 0; max-height: 340px; overflow-y: auto; }
.bell-item {
  display: flex; align-items: flex-start; gap: 10px;
  width: 100%;
  padding: 10px 14px;
  background: none; border: 0; border-bottom: 1px solid var(--border);
  text-align: left;
  font: inherit;
  color: var(--text);
  cursor: pointer;
}
.bell-list li:last-child .bell-item { border-bottom: 0; }
.bell-item:hover { background: var(--surface-2); }
.bell-icon { font-size: 1rem; line-height: 1.4; }
.bell-item-body { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
.bell-item-body strong { font-size: .88rem; }
.bell-snippet { font-size: .8rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.bell-time { font-size: .74rem; }

.bell-footer {
  display: block;
  text-align: center;
  padding: 10px;
  font-size: .85rem;
  font-weight: 600;
  color: var(--primary);
  text-decoration: none;
  border-top: 1px solid var(--border);
}
.bell-footer:hover { background: var(--surface-2); }

@keyframes bell-ring {
  0%, 85%, 100% { transform: rotate(0); }
  87% { transform: rotate(-10deg); }
  89% { transform: rotate(8deg); }
  91% { transform: rotate(-6deg); }
  93% { transform: rotate(4deg); }
  95% { transform: rotate(0); }
}
</style>
