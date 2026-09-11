<script setup lang="ts">
interface Dashboard {
  employees: { total: number; active: number; on_leave: number; terminated: number }
  by_department: { department: string; employees: number }[]
  payroll: { monthly_total: number; average_salary: number | null }
  recent_hires: { id: number; full_name: string; job_title: string; hired_on: string; department?: { name: string } }[]
  recent_changes: { id: number; item_type: string; event: string; created_at: string; changed_by: string | null }[]
  notifications: { unread: number }
}

const api = useApi()
const { data, pending, error, refresh } = useAsyncData(
  "dashboard",
  () => api<{ data: Dashboard }>("/api/v1/dashboard"),
  { lazy: true },
)

const d = computed(() => data.value?.data)
const maxDept = computed(() => Math.max(1, ...(d.value?.by_department.map((x) => x.employees) ?? [1])))

const eventLabel: Record<string, string> = { create: "criou", update: "editou", destroy: "removeu" }
const modelLabel: Record<string, string> = { Employee: "um funcionário", Department: "um departamento" }

function describeChange(v: { event: string; item_type: string }): string {
  return `${eventLabel[v.event] ?? v.event} ${modelLabel[v.item_type] ?? `um registro de ${v.item_type}`}`
}
</script>

<template>
  <div class="stack">
    <div class="row" style="justify-content: space-between">
      <div>
        <h1>Dashboard</h1>
        <p class="muted">Visão geral do quadro de funcionários</p>
      </div>
      <button class="btn btn-ghost btn-sm" type="button" @click="refresh()">Atualizar</button>
    </div>

    <p v-if="pending" class="muted">Carregando…</p>
    <p v-else-if="error" class="alert alert-danger">Não foi possível carregar o dashboard.</p>

    <template v-else-if="d">
      <div class="grid grid-4">
        <StatCard label="Funcionários" :value="d.employees.total" />
        <StatCard label="Ativos" :value="d.employees.active" tone="success" />
        <StatCard label="Afastados" :value="d.employees.on_leave" tone="warning" />
        <StatCard label="Desligados" :value="d.employees.terminated" tone="danger" />
      </div>

      <div class="grid grid-2">
        <div class="card">
          <h2>Folha de pagamento</h2>
          <div class="stack" style="gap: 10px">
            <div class="row" style="justify-content: space-between">
              <span class="muted">Total mensal (ativos)</span>
              <strong>{{ currency(d.payroll.monthly_total) }}</strong>
            </div>
            <div class="row" style="justify-content: space-between">
              <span class="muted">Salário médio</span>
              <strong>{{ currency(d.payroll.average_salary) }}</strong>
            </div>
            <div class="row" style="justify-content: space-between">
              <span class="muted">Notificações não lidas</span>
              <span class="badge">{{ d.notifications.unread }}</span>
            </div>
          </div>
        </div>

        <div class="card">
          <h2>Funcionários por departamento</h2>
          <div class="stack" style="gap: 10px">
            <div v-for="dep in d.by_department" :key="dep.department" class="bar-row">
              <span class="bar-label">{{ dep.department }}</span>
              <span class="bar-track">
                <span class="bar-fill" :style="{ width: `${(dep.employees / maxDept) * 100}%` }" />
              </span>
              <span class="bar-value">{{ dep.employees }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="grid grid-2">
        <div class="card">
          <h2>Contratações recentes</h2>
          <ul class="list">
            <li v-for="emp in d.recent_hires" :key="emp.id">
              <div>
                <strong>{{ emp.full_name }}</strong>
                <span class="muted"> · {{ emp.job_title }}</span>
              </div>
              <span class="muted">{{ emp.department?.name }} — {{ formatDate(emp.hired_on) }}</span>
            </li>
          </ul>
        </div>

        <div class="card">
          <h2>Alterações recentes</h2>
          <ul class="list">
            <li v-for="v in d.recent_changes" :key="v.id">
              <div class="change-line">
                <strong>{{ v.changed_by ?? "Sistema" }}</strong>
                <span class="muted">{{ describeChange(v) }}</span>
              </div>
              <span class="muted">{{ formatDateTime(v.created_at) }}</span>
            </li>
          </ul>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
h1 { font-size: 1.4rem; }
.btn-sm { padding: 6px 12px; font-size: .85rem; }
.bar-row { display: grid; grid-template-columns: 130px 1fr 32px; align-items: center; gap: 10px; font-size: .9rem; }
.bar-label { color: var(--text-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.bar-track { background: var(--surface-2); border-radius: 999px; height: 10px; overflow: hidden; }
.bar-fill { display: block; height: 100%; background: var(--primary); border-radius: 999px; }
.bar-value { text-align: right; font-weight: 700; }
.list { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; }
.list li { padding: 10px 0; border-bottom: 1px solid var(--border); display: flex; flex-direction: column; gap: 2px; font-size: .9rem; }
.list li:last-child { border-bottom: 0; }
.change-line { display: flex; gap: 5px; flex-wrap: wrap; }
</style>
