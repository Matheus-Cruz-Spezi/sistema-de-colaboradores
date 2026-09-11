<script setup lang="ts">
const toasts = useToastsStore()
</script>

<template>
  <div class="toast-stack" aria-live="polite">
    <TransitionGroup name="toast" tag="div" class="toast-list">
      <div
        v-for="t in toasts.items"
        :key="t.id"
        class="toast"
        :class="`toast-${notificationTone(t.category)}`"
      >
        <span class="toast-icon">{{ notificationIcon(t.category) }}</span>
        <div class="toast-body">
          <strong>{{ t.title }}</strong>
          <span v-if="t.body" class="muted">{{ t.body }}</span>
        </div>
        <button type="button" class="toast-close" aria-label="Fechar notificação" @click="toasts.dismiss(t.id)">✕</button>
      </div>
    </TransitionGroup>
  </div>
</template>

<style scoped>
.toast-stack {
  position: fixed;
  top: 16px;
  right: 16px;
  left: 16px;
  z-index: 100;
  display: flex;
  justify-content: flex-end;
  pointer-events: none;
}
.toast-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  width: min(360px, 100%);
}
.toast {
  pointer-events: auto;
  display: flex;
  align-items: flex-start;
  gap: 10px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-left: 4px solid var(--primary);
  border-radius: var(--radius-sm);
  box-shadow: var(--shadow);
  padding: 12px 14px;
}
.toast-success { border-left-color: var(--success); }
.toast-warning { border-left-color: var(--warning); }
.toast-danger { border-left-color: var(--danger); }
.toast-icon { font-size: 1.1rem; line-height: 1.3; }
.toast-body { display: flex; flex-direction: column; gap: 2px; font-size: .88rem; min-width: 0; }
.toast-body strong { font-size: .9rem; }
.toast-close {
  margin-left: auto;
  background: none;
  border: 0;
  color: var(--text-muted);
  cursor: pointer;
  font-size: .85rem;
  line-height: 1;
  padding: 2px;
  flex: none;
}
.toast-close:hover { color: var(--text); }

.toast-enter-active,
.toast-leave-active { transition: opacity .25s ease, transform .25s ease; }
.toast-enter-from,
.toast-leave-to { opacity: 0; transform: translateX(24px); }

@media (prefers-reduced-motion: reduce) {
  .toast-enter-active, .toast-leave-active { transition: none; }
}
</style>
