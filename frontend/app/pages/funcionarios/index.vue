<script setup lang="ts">
interface Employee {
  id: number
  full_name: string
  job_title: string
  employment_status: string
  department?: { name: string }
  department_id: number
}
interface Meta { page: number; pages: number; count: number; per_page: number }
interface Department { id: number; name: string }

const api = useApi()

const q = ref("")
const qDebounced = ref("")
const departmentId = ref("")
const status = ref("")
const sort = ref("full_name")
const direction = ref<"asc" | "desc">("asc")
const page = ref(1)

let debounceTimer: ReturnType<typeof setTimeout>
watch(q, (value) => {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => {
    qDebounced.value = value
    page.value = 1
  }, 300)
})
watch([departmentId, status, sort, direction], () => (page.value = 1))

const { data: deptData } = useAsyncData("departments-options", () =>
  api<{ data: Department[] }>("/api/v1/departments", { query: { per_page: 100, sort: "name" } }),
)
const departments = computed(() => deptData.value?.data ?? [])

const { data, pending, error } = useAsyncData(
  "employees-list",
  () =>
    api<{ data: Employee[]; meta: Meta }>("/api/v1/employees", {
      query: {
        q: qDebounced.value || undefined,
        department_id: departmentId.value || undefined,
        status: status.value || undefined,
        sort: sort.value,
        direction: direction.value,
        page: page.value,
        per_page: 10,
      },
    }),
  { lazy: true, watch: [qDebounced, departmentId, status, sort, direction, page] },
)

const rows = computed(() => data.value?.data ?? [])
const meta = computed(() => data.value?.meta)

function toggleSort(column: string) {
  if (sort.value === column) direction.value = direction.value === "asc" ? "desc" : "asc"
  else {
    sort.value = column
    direction.value = "asc"
  }
}
function sortArrow(column: string) {
  return sort.value === column ? (direction.value === "asc" ? "↑" : "↓") : ""
}
</script>

<template>
  <div class="stack">
    <div>
      <h1>Funcionários</h1>
      <p class="muted">Selecione um perfil para ver os detalhes</p>
    </div>

    <div class="card toolbar">
      <input v-model="q" class="input" type="search" placeholder="Buscar por nome, cargo ou e-mail…" />
      <select v-model="departmentId" class="input">
        <option value="">Todos os departamentos</option>
        <option v-for="d in departments" :key="d.id" :value="d.id">{{ d.name }}</option>
      </select>
      <select v-model="status" class="input">
        <option value="">Todas as situações</option>
        <option value="active">Ativo</option>
        <option value="on_leave">Afastado</option>
        <option value="terminated">Desligado</option>
      </select>
    </div>

    <div class="card table-card">
      <p v-if="pending" class="muted pad">Carregando…</p>
      <p v-else-if="error" class="alert alert-danger">Não foi possível carregar a lista.</p>
      <p v-else-if="rows.length === 0" class="muted pad">Nenhum funcionário encontrado.</p>

      <table v-else class="table">
        <thead>
          <tr>
            <th class="sortable" @click="toggleSort('full_name')">Nome {{ sortArrow("full_name") }}</th>
            <th class="sortable" @click="toggleSort('job_title')">Cargo {{ sortArrow("job_title") }}</th>
            <th>Departamento</th>
            <th class="sortable" @click="toggleSort('employment_status')">Situação {{ sortArrow("employment_status") }}</th>
            <th aria-label="abrir" />
          </tr>
        </thead>
        <tbody>
          <tr v-for="e in rows" :key="e.id" class="clickable" @click="navigateTo(`/funcionarios/${e.id}`)">
            <td><strong>{{ e.full_name }}</strong></td>
            <td>{{ e.job_title }}</td>
            <td>{{ e.department?.name ?? "—" }}</td>
            <td><span class="badge" :class="`badge-${statusTone(e.employment_status)}`">{{ statusLabel(e.employment_status) }}</span></td>
            <td class="chev">›</td>
          </tr>
        </tbody>
      </table>

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
.toolbar { display: grid; gap: 10px; }
@media (min-width: 720px) { .toolbar { grid-template-columns: 2fr 1fr 1fr; } }
.table-card { padding: 0; overflow: hidden; }
.pad { padding: 20px; }
.alert { margin: 16px; }
.table { width: 100%; border-collapse: collapse; font-size: .92rem; }
.table th, .table td { text-align: left; padding: 12px 16px; border-bottom: 1px solid var(--border); }
.table th { font-size: .74rem; text-transform: uppercase; letter-spacing: .05em; color: var(--text-muted); background: var(--surface-2); }
.table tbody tr:last-child td { border-bottom: 0; }
.sortable { cursor: pointer; user-select: none; }
.sortable:hover { color: var(--text); }
.clickable { cursor: pointer; }
.clickable:hover { background: var(--surface-2); }
.chev { text-align: right; color: var(--text-muted); font-size: 1.2rem; width: 1px; }
.btn-sm { padding: 6px 12px; font-size: .85rem; }
.pager { display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 14px 16px; border-top: 1px solid var(--border); flex-wrap: wrap; }
</style>
