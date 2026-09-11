<script setup lang="ts">
interface Profile {
  user: { id: number; email: string; role: string; created_at: string }
  employee: {
    id: number
    full_name: string
    email: string
    document_number: string
    job_title: string
    phone: string | null
    employment_status: string
    hired_on: string
    birth_date: string | null
    salary: number | null
    department?: { name: string }
  } | null
}

const api = useApi()

const { data, pending, error } = useAsyncData("profile", () => api<Profile>("/api/v1/profile"), { lazy: true })

const roleLabel: Record<string, string> = { admin: "Administrador", manager: "Gestor", employee: "Colaborador" }
</script>

<template>
  <div class="stack">
    <div>
      <h1>Perfil</h1>
      <p class="muted">Seus dados de acesso e ficha de funcionário</p>
    </div>

    <p v-if="pending" class="muted">Carregando…</p>
    <p v-else-if="error" class="alert alert-danger">Não foi possível carregar o perfil.</p>

    <template v-else-if="data">
      <div class="card">
        <h2>Conta</h2>
        <dl class="fields">
          <div><dt>E-mail</dt><dd>{{ data.user.email }}</dd></div>
          <div><dt>Perfil de acesso</dt><dd><span class="badge">{{ roleLabel[data.user.role] ?? data.user.role }}</span></dd></div>
          <div><dt>Usuário desde</dt><dd>{{ formatDate(data.user.created_at) }}</dd></div>
        </dl>
      </div>

      <div v-if="data.employee" class="card">
        <h2>Ficha de funcionário</h2>
        <dl class="fields">
          <div><dt>Nome completo</dt><dd>{{ data.employee.full_name }}</dd></div>
          <div><dt>Cargo</dt><dd>{{ data.employee.job_title }}</dd></div>
          <div><dt>Departamento</dt><dd>{{ data.employee.department?.name ?? "—" }}</dd></div>
          <div>
            <dt>Situação</dt>
            <dd><span class="badge" :class="`badge-${statusTone(data.employee.employment_status)}`">{{ statusLabel(data.employee.employment_status) }}</span></dd>
          </div>
          <div><dt>CPF</dt><dd>{{ data.employee.document_number }}</dd></div>
          <div><dt>Telefone</dt><dd>{{ data.employee.phone ?? "—" }}</dd></div>
          <div><dt>Admissão</dt><dd>{{ formatDate(data.employee.hired_on) }}</dd></div>
          <div><dt>Nascimento</dt><dd>{{ formatDate(data.employee.birth_date) }}</dd></div>
          <div><dt>Salário</dt><dd>{{ currency(data.employee.salary) }}</dd></div>
        </dl>
        <p class="muted note">Edições de perfil são feitas pelo administrador na tela <strong>Funcionários</strong>.</p>
      </div>

      <div v-else class="card">
        <p class="muted">Sua conta ainda não está vinculada a uma ficha de funcionário.</p>
      </div>
    </template>
  </div>
</template>

<style scoped>
h1 { font-size: 1.4rem; }
.fields { margin: 0; display: grid; gap: 14px; }
@media (min-width: 560px) { .fields { grid-template-columns: 1fr 1fr; } }
.fields dt { font-size: .78rem; text-transform: uppercase; letter-spacing: .05em; color: var(--text-muted); font-weight: 600; margin-bottom: 2px; }
.fields dd { margin: 0; font-weight: 500; }
.note { margin-top: 16px; padding-top: 12px; border-top: 1px solid var(--border); font-size: .85rem; }
</style>
