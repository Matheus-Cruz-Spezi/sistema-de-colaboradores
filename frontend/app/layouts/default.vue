<script setup lang="ts">
const auth = useAuthStore()
const route = useRoute()

const nav = computed(() => [
  ...(auth.canSeeDashboard ? [{ to: "/", label: "Dashboard" }] : []),
  ...(auth.canBrowseProfiles ? [{ to: "/funcionarios", label: "Funcionários" }] : []),
  { to: "/perfil", label: "Perfil" },
])

function logout() {
  auth.logout()
  navigateTo("/login")
}
</script>

<template>
  <div>
    <header class="topbar">
      <div class="topbar-inner">
        <div class="brand">
          <span class="brand-mark">RH</span>
          <span class="brand-name">Meu Projeto Ruby</span>
        </div>

        <nav class="nav">
          <NuxtLink
            v-for="item in nav"
            :key="item.to"
            :to="item.to"
            class="nav-link"
            :class="{ active: item.to === '/' ? route.path === '/' : route.path.startsWith(item.to) }"
          >
            {{ item.label }}
          </NuxtLink>
        </nav>

        <div class="user">
          <NotificationBell />
          <div class="user-info">
            <span class="user-email">{{ auth.user?.email }}</span>
            <span class="badge">{{ auth.roleLabel }}</span>
          </div>
          <button class="btn btn-ghost btn-sm" type="button" @click="logout">Sair</button>
        </div>
      </div>
    </header>

    <main class="container">
      <slot />
    </main>
  </div>
</template>

<style scoped>
.topbar {
  background: var(--surface);
  border-bottom: 1px solid var(--border);
  position: sticky;
  top: 0;
  z-index: 10;
}
.topbar-inner {
  max-width: 1080px;
  margin: 0 auto;
  padding: 0 16px;
  min-height: 60px;
  display: flex;
  align-items: center;
  gap: 24px;
  flex-wrap: wrap;
}
.brand { display: flex; align-items: center; gap: 10px; font-weight: 700; }
.brand-mark {
  background: var(--primary);
  color: #fff;
  width: 30px; height: 30px;
  border-radius: 8px;
  display: grid; place-items: center;
  font-size: .8rem;
}
.nav { display: flex; gap: 4px; margin-right: auto; }
.nav-link {
  padding: 8px 12px;
  border-radius: 8px;
  text-decoration: none;
  color: var(--text-muted);
  font-weight: 600;
  font-size: .92rem;
}
.nav-link:hover { background: var(--surface-2); color: var(--text); }
.nav-link.active { background: var(--primary-soft); color: var(--primary); }
.user { display: flex; align-items: center; gap: 12px; }
.user-info { display: flex; flex-direction: column; align-items: flex-end; gap: 3px; }
.user-email { font-size: .85rem; color: var(--text-muted); }
.btn-sm { padding: 6px 12px; font-size: .85rem; }
</style>
