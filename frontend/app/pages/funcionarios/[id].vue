<script setup lang="ts">
interface Employee {
  id: number
  full_name: string
  email: string
  document_number: string
  job_title: string
  phone: string | null
  employment_status: string
  hired_on: string
  terminated_on: string | null
  birth_date: string | null
  salary: number | null
  department_id: number
  user_id: number | null
  user_role: string | null
  department?: { name: string }
}
interface Department { id: number; name: string }

const route = useRoute()
const auth = useAuthStore()
const api = useApi()
const id = route.params.id as string

const { data, pending, error, refresh } = useAsyncData(`employee-${id}`, () =>
  api<{ data: Employee }>(`/api/v1/employees/${id}`),
  { lazy: true },
)
const employee = computed(() => data.value?.data)

const { data: deptData } = useAsyncData("departments-options", () =>
  api<{ data: Department[] }>("/api/v1/departments", { query: { per_page: 100, sort: "name" } }),
)
const departments = computed(() => deptData.value?.data ?? [])

// Regra de edição (espelha EmployeePolicy; a API é a palavra final).
const isOwnProfile = computed(() => employee.value?.user_id === auth.user?.id)
const targetIsAdmin = computed(() => employee.value?.user_role === "admin")
const canEdit = computed(() => auth.isAdmin && !isOwnProfile.value && !targetIsAdmin.value)

const lockReason = computed(() => {
  if (auth.isManager) return "Gestores não podem editar perfis. Apenas administradores editam os perfis de colaboradores e gestores."
  if (isOwnProfile.value) return "Você não pode editar o próprio perfil."
  if (targetIsAdmin.value) return "Não é possível editar o perfil de outro administrador."
  return "Você não tem permissão para editar este perfil."
})

const editing = ref(false)
const saving = ref(false)
const formError = ref("")
const flash = ref("")
const lockShake = ref(false)
const lockMessage = ref("")

const STATUS_OPTIONS = [
  { value: "active", label: "Ativo" },
  { value: "on_leave", label: "Afastado" },
  { value: "terminated", label: "Desligado" },
]

const form = reactive({
  job_title: "",
  department_id: "" as number | string,
  phone: "",
  employment_status: "",
  terminated_on: "",
})

function startEdit() {
  if (!employee.value) return
  form.job_title = employee.value.job_title
  form.department_id = employee.value.department_id
  form.phone = employee.value.phone ?? ""
  form.employment_status = employee.value.employment_status
  form.terminated_on = employee.value.terminated_on ?? ""
  formError.value = ""
  flash.value = ""
  lockMessage.value = ""
  editing.value = true
}

async function save() {
  if (!employee.value) return
  saving.value = true
  formError.value = ""
  try {
    await api(`/api/v1/employees/${employee.value.id}`, {
      method: "PATCH",
      body: {
        employee: {
          job_title: form.job_title,
          department_id: form.department_id,
          phone: form.phone || null,
          employment_status: form.employment_status,
          // Some desligamento salvo quando a situação não é "Desligado".
          terminated_on: form.employment_status === "terminated" ? (form.terminated_on || null) : null,
        },
      },
    })
    await refresh()
    editing.value = false
    flash.value = "Perfil atualizado."
  } catch (e: unknown) {
    const err = e as { data?: { error?: string; errors?: string[] } }
    formError.value = err?.data?.errors?.join(" · ") || err?.data?.error || "Não foi possível salvar."
  } finally {
    saving.value = false
  }
}

function blockedClick() {
  lockShake.value = true
  lockMessage.value = lockReason.value
  setTimeout(() => (lockShake.value = false), 600)
}
</script>

<template>
  <div class="stack">
    <NuxtLink to="/funcionarios" class="back">‹ Funcionários</NuxtLink>

    <p v-if="pending" class="muted">Carregando…</p>
    <p v-else-if="error" class="alert alert-danger">Perfil não encontrado ou sem acesso.</p>

    <template v-else-if="employee">
      <div class="row head">
        <div>
          <h1>{{ employee.full_name }}</h1>
          <p class="muted">{{ employee.job_title }} · {{ employee.department?.name }}</p>
        </div>

        <button v-if="canEdit && !editing" type="button" class="btn btn-ghost btn-sm" @click="startEdit">✏️ Editar</button>
        <button
          v-else-if="(auth.isManager || auth.isAdmin) && !editing"
          type="button"
          class="btn btn-ghost btn-sm btn-locked"
          @click="blockedClick"
        >
          <span class="lock" :class="{ shake: lockShake }">🔒</span> Editar
        </button>
      </div>

      <p v-if="lockMessage" class="alert alert-danger">{{ lockMessage }}</p>
      <p v-if="flash" class="alert alert-success">{{ flash }}</p>

      <div class="card">
        <h2>Ficha de funcionário</h2>

        <dl v-if="!editing" class="fields">
          <div><dt>Nome completo</dt><dd>{{ employee.full_name }}</dd></div>
          <div><dt>E-mail</dt><dd>{{ employee.email }}</dd></div>
          <div><dt>Cargo</dt><dd>{{ employee.job_title }}</dd></div>
          <div><dt>Departamento</dt><dd>{{ employee.department?.name ?? "—" }}</dd></div>
          <div><dt>Telefone</dt><dd>{{ employee.phone ?? "—" }}</dd></div>
          <div>
            <dt>Situação</dt>
            <dd><span class="badge" :class="`badge-${statusTone(employee.employment_status)}`">{{ statusLabel(employee.employment_status) }}</span></dd>
          </div>
          <div><dt>CPF</dt><dd>{{ employee.document_number }}</dd></div>
          <div><dt>Admissão</dt><dd>{{ formatDate(employee.hired_on) }}</dd></div>
          <div v-if="employee.employment_status === 'terminated'"><dt>Desligamento</dt><dd>{{ formatDate(employee.terminated_on) }}</dd></div>
          <div><dt>Salário</dt><dd>{{ currency(employee.salary) }}</dd></div>
        </dl>

        <form v-else class="edit-form" @submit.prevent="save">
          <div class="field">
            <label for="job_title">Cargo</label>
            <input id="job_title" v-model="form.job_title" class="input" required />
          </div>
          <div class="field">
            <label for="department_id">Departamento</label>
            <select id="department_id" v-model="form.department_id" class="input" required>
              <option v-for="d in departments" :key="d.id" :value="d.id">{{ d.name }}</option>
            </select>
          </div>
          <div class="field">
            <label for="phone">Telefone</label>
            <input id="phone" v-model="form.phone" class="input" />
          </div>
          <div class="field">
            <label for="employment_status">Situação</label>
            <select id="employment_status" v-model="form.employment_status" class="input" required>
              <option v-for="opt in STATUS_OPTIONS" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
            </select>
          </div>
          <div v-if="form.employment_status === 'terminated'" class="field">
            <label for="terminated_on">Data de desligamento</label>
            <input id="terminated_on" v-model="form.terminated_on" class="input" type="date" />
          </div>

          <p v-if="formError" class="alert alert-danger">{{ formError }}</p>

          <div class="row">
            <button class="btn btn-sm" type="submit" :disabled="saving">{{ saving ? "Salvando…" : "Salvar" }}</button>
            <button class="btn btn-ghost btn-sm" type="button" @click="editing = false">Cancelar</button>
          </div>
        </form>
      </div>
    </template>
  </div>
</template>

<style scoped>
h1 { font-size: 1.4rem; }
.back { color: var(--text-muted); text-decoration: none; font-weight: 600; font-size: .9rem; }
.back:hover { color: var(--text); }
.head { justify-content: space-between; align-items: flex-start; }
.btn-sm { padding: 6px 12px; font-size: .85rem; }
.fields { margin: 0; display: grid; gap: 14px; }
@media (min-width: 560px) { .fields { grid-template-columns: 1fr 1fr; } }
.fields dt { font-size: .78rem; text-transform: uppercase; letter-spacing: .05em; color: var(--text-muted); font-weight: 600; margin-bottom: 2px; }
.fields dd { margin: 0; font-weight: 500; }
.edit-form { display: grid; gap: 4px; max-width: 420px; }
.alert-success { background: rgba(22, 163, 74, .14); color: var(--success); }

.btn-locked { opacity: .45; cursor: not-allowed; filter: grayscale(0.6); }
.btn-locked:hover { filter: grayscale(0.6); background: transparent; }
.lock { display: inline-block; animation: lock-wiggle 2.6s ease-in-out infinite; }
.lock.shake { animation: lock-shake .6s ease; }
@keyframes lock-wiggle {
  0%, 88%, 100% { transform: rotate(0); }
  90% { transform: rotate(-12deg); }
  93% { transform: rotate(10deg); }
  96% { transform: rotate(-6deg); }
}
@keyframes lock-shake {
  0%, 100% { transform: translateX(0) rotate(0); }
  20% { transform: translateX(-3px) rotate(-14deg); }
  40% { transform: translateX(3px) rotate(12deg); }
  60% { transform: translateX(-2px) rotate(-8deg); }
  80% { transform: translateX(2px) rotate(6deg); }
}
</style>
