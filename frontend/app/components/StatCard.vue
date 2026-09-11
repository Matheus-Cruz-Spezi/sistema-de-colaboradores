<script setup lang="ts">
defineProps<{
  label: string
  value: string | number
  hint?: string
  tone?: "default" | "success" | "warning" | "danger"
}>()
</script>

<template>
  <div class="stat card" :class="`tone-${tone ?? 'default'}`">
    <span class="stat-label">{{ label }}</span>
    <span class="stat-value">{{ value }}</span>
    <span v-if="hint" class="stat-hint muted">{{ hint }}</span>
  </div>
</template>

<style scoped>
.stat { padding: 16px 18px; display: flex; flex-direction: column; gap: 4px; }
.stat-label { font-size: .78rem; text-transform: uppercase; letter-spacing: .05em; color: var(--text-muted); font-weight: 600; }
.stat-value { font-size: 1.9rem; font-weight: 700; line-height: 1.1; }
.stat-hint { font-size: .8rem; }
.tone-success .stat-value { color: var(--success); }
.tone-warning .stat-value { color: var(--warning); }
.tone-danger .stat-value { color: var(--danger); }
</style>
