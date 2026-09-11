const PUBLIC_ROUTES = ["/login"]

export default defineNuxtRouteMiddleware((to) => {
  const auth = useAuthStore()
  if (!auth.ready) auth.hydrate()

  const isPublic = PUBLIC_ROUTES.includes(to.path)

  if (!auth.isAuthenticated && !isPublic) {
    return navigateTo("/login")
  }
  if (auth.isAuthenticated && to.path === "/login") {
    return navigateTo(auth.canSeeDashboard ? "/" : "/perfil")
  }
  // Colaborador não tem dashboard gerencial nem a lista de perfis.
  if (auth.isAuthenticated && to.path === "/" && !auth.canSeeDashboard) {
    return navigateTo("/perfil")
  }
  if (auth.isAuthenticated && to.path.startsWith("/funcionarios") && !auth.canBrowseProfiles) {
    return navigateTo("/perfil")
  }
})
