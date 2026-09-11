// https://nuxt.com/docs/api/configuration/nuxt-config

// Alvo do proxy /api do servidor Nuxt.
// Docker: http://backend:3000 | local sem Docker: http://localhost:3001
const apiTarget = process.env.NUXT_API_INTERNAL || "http://localhost:3001"

export default defineNuxtConfig({
  compatibilityDate: "2025-07-15",
  devtools: { enabled: true },

  // App autenticado (token no navegador) — renderização no cliente.
  ssr: false,

  modules: ["@pinia/nuxt"],

  css: ["~/assets/css/main.css"],

  app: {
    head: {
      title: "RH · Colaborador Spezi",
      htmlAttrs: { lang: "pt-BR" },
      meta: [
        { charset: "utf-8" },
        { name: "viewport", content: "width=device-width, initial-scale=1" },
      ],
    },
  },

  devServer: {
    host: "0.0.0.0",
    port: 3000,
  },

  runtimeConfig: {
    public: {
      // Vazio = mesma origem; o servidor Nuxt faz proxy de /api para a API Rails.
      apiBase: "",
    },
  },

  nitro: {
    routeRules: {
      "/api/**": { proxy: `${apiTarget}/api/**` },
    },
  },

  vite: {
    server: {
      watch: { usePolling: true },
    },
  },
})
