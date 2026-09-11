# Frontend — Nuxt 4

Interface web da gestão de funcionários. Nuxt 4 (Vue 3) em modo **SPA**
(`ssr: false`), estado com **Pinia**, CSS próprio.

## Rodar

**Com Docker (recomendado)** — junto da stack, a partir da raiz:

```bash
docker compose up
```

http://localhost:3000

**Local (sem Docker):**

```bash
npm install
npm run dev          # usa http://localhost:3001 como API
```

## Telas

| Rota | Arquivo | O que faz |
|------|---------|-----------|
| `/login` | `app/pages/login.vue` | `POST /api/v1/login`, guarda o token no `localStorage` |
| `/` | `app/pages/index.vue` | Dashboard (`GET /api/v1/dashboard`) — admin/gestor |
| `/perfil` | `app/pages/perfil.vue` | Perfil (`GET /api/v1/profile`) — conta + ficha |

## Estrutura (`app/`)

```
app/
├── app.vue                    # <NuxtLayout><NuxtPage/></NuxtLayout>
├── assets/css/main.css        # design system (variáveis CSS, claro/escuro)
├── layouts/{default,auth}.vue  # shell com nav / layout centrado do login
├── pages/                     # login, index (dashboard), perfil
├── components/StatCard.vue
├── stores/auth.ts             # Pinia: login/logout, token, papel
├── composables/useApi.ts      # $fetch com Authorization + tratamento de 401
├── middleware/auth.global.ts  # protege rotas; colaborador não vê Dashboard
├── plugins/auth.client.ts     # restaura a sessão no boot
└── utils/format.ts            # moeda, datas, rótulos
```

## Comunicação com a API

Caminhos relativos (`/api/...`). O servidor Nuxt encaminha `/api/**` para o Rails
via `nitro.routeRules` em `nuxt.config.ts` (alvo `NUXT_API_INTERNAL`, padrão
`http://backend:3000` no Docker). O navegador só fala com o próprio Nuxt — sem CORS.

## Scripts

| Comando | Ação |
|---------|------|
| `npm run dev` | servidor de desenvolvimento |
| `npm run build` | build de produção (Nitro) |
| `npm run preview` | pré-visualiza o build |
