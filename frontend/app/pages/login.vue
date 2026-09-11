<script setup lang="ts">
definePageMeta({ layout: "auth" })

const auth = useAuthStore()

const email = ref("")
const password = ref("")
const error = ref("")
const loading = ref(false)

const demoAccounts = [
  { label: "Administrador", email: "admin@empresa.com" },
  { label: "Gestor", email: "gestor@empresa.com" },
  { label: "Colaborador", email: "funcionario@empresa.com" },
]

function useDemo(demoEmail: string) {
  email.value = demoEmail
  password.value = "password123"
}

async function submit() {
  loading.value = true
  error.value = ""
  try {
    await auth.login(email.value, password.value)
    await navigateTo(auth.canSeeDashboard ? "/" : "/perfil")
  } catch (e: unknown) {
    const err = e as { data?: { error?: string } }
    error.value = err?.data?.error || "Não foi possível entrar. Verifique o e-mail e a senha."
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login card">
    <div class="head">
      <span class="brand-mark">RH</span>
      <h1>Acessar o sistema</h1>
      <p class="muted">Gestão de funcionários — Meu Projeto Ruby</p>
    </div>

    <form @submit.prevent="submit">
      <div class="field">
        <label for="email">E-mail</label>
        <input id="email" v-model="email" class="input" type="email" autocomplete="username" required />
      </div>

      <div class="field">
        <label for="password">Senha</label>
        <input id="password" v-model="password" class="input" type="password" autocomplete="current-password" required />
      </div>

      <p v-if="error" class="alert alert-danger">{{ error }}</p>

      <button class="btn" type="submit" :disabled="loading" style="width: 100%">
        {{ loading ? "Entrando…" : "Entrar" }}
      </button>
    </form>

    <div class="demo">
      <span class="muted">Contas de demonstração:</span>
      <div class="row">
        <button
          v-for="acc in demoAccounts"
          :key="acc.email"
          type="button"
          class="btn btn-ghost btn-sm"
          @click="useDemo(acc.email)"
        >
          {{ acc.label }}
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.login { width: 100%; max-width: 380px; }
.head { text-align: center; margin-bottom: 20px; }
.head h1 { font-size: 1.25rem; margin: 12px 0 4px; }
.brand-mark {
  display: inline-grid; place-items: center;
  width: 44px; height: 44px;
  background: var(--primary); color: #fff;
  border-radius: 12px; font-weight: 700;
}
.demo { margin-top: 20px; padding-top: 16px; border-top: 1px solid var(--border); font-size: .85rem; display: flex; flex-direction: column; gap: 8px; }
.btn-sm { padding: 6px 10px; font-size: .82rem; }
</style>
