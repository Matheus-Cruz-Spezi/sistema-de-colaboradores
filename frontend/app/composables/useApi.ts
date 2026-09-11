/**
 * Cliente HTTP da API. Anexa o token do usuário e trata 401 (sessão expirada).
 * Caminhos relativos (`/api/...`) — o servidor Nuxt faz proxy para o Rails.
 */
export function useApi() {
  const auth = useAuthStore()

  return $fetch.create({
    onRequest({ options }) {
      if (auth.token) {
        const headers = new Headers(options.headers as HeadersInit)
        headers.set("Authorization", `Bearer ${auth.token}`)
        options.headers = headers
      }
    },
    onResponseError({ response }) {
      if (response.status === 401) {
        auth.logout()
        if (import.meta.client) navigateTo("/login")
      }
    },
  })
}
