// Restaura a sessão salva antes da primeira navegação.
export default defineNuxtPlugin(() => {
  const auth = useAuthStore()
  if (!auth.ready) auth.hydrate()
})
