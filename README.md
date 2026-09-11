# Meu Projeto Ruby

Ambiente full-stack em Docker:

```
Nuxt 4 (frontend)  →  Rails 8 API (backend)  →  PostgreSQL 16 (db)
```

## Estrutura

```
.
├── backend/            # API Ruby on Rails 8 (modo --api)
├── frontend/           # aplicação Nuxt 4 (Vue 3)
├── docker/
│   ├── backend/Dockerfile
│   └── frontend/Dockerfile
├── docker-compose.yml  # serviços: frontend + backend + db
├── .env                # variáveis locais (NÃO versionar)
└── .env.example        # modelo das variáveis
```

## Pré-requisitos

- Docker + Docker Compose

## Primeiro uso

```bash
cp .env.example .env      # ajuste portas / UID / GID se necessário
docker compose up --build
```

O `backend` roda `bin/rails db:prepare` automaticamente na subida (cria e migra o banco).
Na **primeira vez** isso leva ~20–40s (migrations + seed); o `frontend` só sobe
depois que o `backend` fica *healthy*, então a página não carrega antes da API estar pronta.

| Serviço | URL | Descrição |
|---------|-----|-----------|
| Frontend (Nuxt) | http://localhost:3000 | interface web (Login / Dashboard / Perfil) |
| Backend (Rails) | http://localhost:3001 | API JSON |
| PostgreSQL | localhost:5434 | acesso do host (na rede Docker é sempre 5432) |

Abra http://localhost:3000, entre com uma conta de seed (ex.: `admin@empresa.com`
/ `password123`) e navegue pelo Dashboard e Perfil.

## Serviços (docker-compose.yml)

- **db** — `postgres:16-alpine`, volume `postgres_data`, healthcheck com `pg_isready`.
- **backend** — build `docker/backend/Dockerfile`, contexto `./backend`. Sobe o Puma
  em `0.0.0.0:3000` (publicado como `3001` no host). Depende do `db` saudável.
- **frontend** — build `docker/frontend/Dockerfile`, contexto `./frontend`. Sobe o
  Nuxt dev server em `0.0.0.0:3000`. Depende do `backend`.

Todos os serviços ficam na network `appnet` e se enxergam pelo nome
(`db`, `backend`, `frontend`).

### Comunicação frontend ↔ backend

O navegador **só acessa o Nuxt** (`http://localhost:3000`). Chamadas a `/api/**`
são encaminhadas pelo servidor Nuxt para a API Rails
(`nitro.routeRules` em `frontend/nuxt.config.ts`, alvo `NUXT_API_INTERNAL` =
`http://backend:3000`). Assim não há CORS entre navegador e backend, e a porta
`3001` não precisa estar acessível ao navegador (útil com encaminhamento de
portas do VS Code / acesso remoto).

A porta `3001` fica publicada só para testar a API direto (curl, Postman).
Rails aceita o host `backend` via `config.hosts << "backend"` em
`backend/config/environments/development.rb`; o `CORS_ORIGINS` continua
configurado para quem chamar a API na 3001.

## Comandos do dia a dia

| Ação | Comando |
|------|---------|
| Subir tudo | `docker compose up` |
| Subir em background | `docker compose up -d` |
| Parar | `docker compose down` |
| Rebuild após mudar Dockerfile/deps | `docker compose up --build` |
| Logs | `docker compose logs -f backend` / `... frontend` |
| Console Rails | `docker compose exec backend bin/rails console` |
| Migrations | `docker compose exec backend bin/rails db:migrate` |
| Testes do backend | `docker compose exec backend bin/rails test` |
| Testes do frontend | `docker compose exec frontend npm test` |
| Shell no backend | `docker compose exec backend bash` |
| Shell no frontend | `docker compose exec frontend sh` |
| psql | `docker compose exec db psql -U postgres meu_projeto_ruby_development` |

## Adicionar dependências

**Backend (gem):**

1. Edite `backend/Gemfile`
2. `docker compose run --rm --user root backend bundle install`
3. `docker compose build backend`

> `json` está preso em `~> 2.9`: a versão 3.x quebra o parser de parâmetros do
> Rails 8.1.3.

**Frontend (npm):**

1. `docker compose exec frontend npm install <pacote>`
   (ou edite `frontend/package.json` e `docker compose build frontend`)

## API REST (`/api/v1`)

Rails em modo `--api`. Serialização com **Alba**, paginação com **Pagy**,
mensagens em **pt-BR** (`rails-i18n`). Todas as rotas de domínio exigem
`Authorization: Bearer <token>` e a **permissão** correspondente ao papel do
usuário (403 quando falta).

### Autenticação (JWT)

`has_secure_password` + gem `jwt`. Token expira em 24h; chave em `JWT_SECRET_KEY`
(fallback `secret_key_base`).

| Método | Rota | Auth | Descrição |
|--------|------|------|-----------|
| GET | `/api/v1/health` | — | Status da API + banco |
| POST | `/api/v1/signup` | — | `{ "user": { "email", "password" } }` → `user` + `token` |
| POST | `/api/v1/login` | — | `{ "email", "password" }` → `user` + `token` |
| GET | `/api/v1/me` | Bearer | Usuário autenticado |
| GET | `/api/v1/profile` | Bearer | Conta + ficha de funcionário do próprio usuário |
| DELETE | `/api/v1/logout` | Bearer | Revoga o token atual |

### Recursos

| Método | Rota | Permissão |
|--------|------|-----------|
| GET | `/api/v1/dashboard` | `dashboard.view` |
| GET/POST | `/api/v1/employees` | `employees.read` / `employees.create` |
| GET/PATCH/DELETE | `/api/v1/employees/:id` | `employees.read` / `employees.update` / `employees.destroy` |
| GET | `/api/v1/employees/:id/history` | (mesma regra do `show`) |
| GET/POST | `/api/v1/departments` | `departments.read` / `departments.manage` |
| GET/PATCH/DELETE | `/api/v1/departments/:id` | `departments.read` / `departments.manage` |
| GET/DELETE | `/api/v1/notifications`, `/:id` | `notifications.read` (sempre escopadas ao usuário) |
| PATCH | `/api/v1/notifications/:id/read`, `/read_all` | `notifications.read` |
| GET | `/api/v1/roles`, `/roles/:id`, `/permissions` | `roles.read` |

### Perfis e autorização

Três perfis (papéis), verificados por **Pundit** (`app/policies/`) além das permissões:

| Perfil | Ver perfis de funcionário | Editar / criar / remover |
|--------|---------------------------|--------------------------|
| **COLABORADOR** (`employee`) | apenas o **próprio** (via `employees.user_id`) | não |
| **MANAGER** (`manager`) | **todos** | não |
| **ADMIN** (`admin`) | **todos** | sim — o próprio e os de colaborador/gestor; **não** o de outro admin |

- `EmployeePolicy::Scope` filtra a listagem: colaborador só recebe o próprio registro.
- `EmployeePolicy#update?` exige `admin` **e** (ser o próprio perfil **ou** o alvo não ser admin).
  `#destroy?` exige `admin` **e** que o alvo não seja um usuário admin.
- Demais recursos (departments, notifications, roles, dashboard) continuam no gate
  por **permissão** do papel (`current_user.can?(...)`).
- Negado → `403 { "error": "Seu perfil de acesso não permite esta ação" }`.

### Listagem: paginação, filtros e ordenação

`GET /api/v1/employees?page=2&per_page=20&sort=hired_on&direction=desc&status=active&department_id=1&q=ana`

- **Paginação**: `page` (1), `per_page` (20, máx. 100)
- **Ordenação**: `sort` (whitelist por recurso) + `direction` (`asc`/`desc`)
- **Filtros de `employees`**: `q` (nome/e-mail/cargo), `status`, `department_id`
- **Filtro de `notifications`**: `unread=true`

### Formato das respostas

```jsonc
// coleção
{ "data": [ { ... } ], "meta": { "page": 1, "per_page": 20, "count": 12, "pages": 1, "prev_page": null, "next_page": null } }
// recurso único
{ "data": { ... } }
// erro de validação (422)         // não encontrado (404)     // sem permissão (403)
{ "errors": ["CPF deve ter 11 dígitos"] }   { "error": "Recurso não encontrado" }   { "error": "Acesso negado: requer a permissão 'employees.create'" }
```

Status usados: `200`, `201`, `204`, `400` (parâmetro ausente), `401` (sem token),
`403` (sem permissão), `404`, `422` (validação / remoção com dependências).

```bash
TOKEN=$(curl -s -X POST localhost:3001/api/v1/login -H 'Content-Type: application/json' \
  -d '{"email":"admin@empresa.com","password":"password123"}' | jq -r .token)
curl -s "localhost:3001/api/v1/employees?per_page=5&sort=salary&direction=desc" \
  -H "Authorization: Bearer $TOKEN"
```

## Frontend (Nuxt 4)

Interface em `frontend/` — Nuxt 4 em modo **SPA** (`ssr: false`), estado de
autenticação com **Pinia**, CSS próprio (tema claro/escuro automático).
Consome a API pelo proxy `/api` do próprio servidor Nuxt (sem CORS).

| Tela | Rota | Descrição |
|------|------|-----------|
| **Login** | `/login` | E-mail + senha → `POST /api/v1/login`; guarda o token no `localStorage`. Botões de conta de demonstração. |
| **Dashboard** | `/` | `GET /api/v1/dashboard` — cards de situação, folha de pagamento, funcionários por departamento, contratações e alterações recentes. Só admin/gestor. |
| **Funcionários** | `/funcionarios` | `GET /api/v1/employees` — lista com busca, filtro por departamento/situação, ordenação e paginação. Admin e gestor. Clicar numa linha abre `/funcionarios/:id`. |
| **Detalhe do funcionário** | `/funcionarios/:id` | `GET /api/v1/employees/:id`. Admin tem **Editar** ativo (cargo, departamento, telefone e **situação** — ativo/afastado/desligado, com data de desligamento → `PATCH`), **exceto** no próprio perfil e no de outro admin. Gestor vê o botão bloqueado (apagado, cadeado animado) com aviso de permissão. |
| **Perfil** | `/perfil` | `GET /api/v1/profile` — conta + ficha do próprio usuário, **incluindo o salário** (somente leitura). Colaborador cai aqui direto. |
| **Notificações** | `/notificacoes` | `GET /api/v1/notifications` — lista paginada, filtro "somente não lidas", marcar como lida/todas, excluir. Todos os perfis. |

- Sino de notificações (`app/components/NotificationBell.vue`) no topo, em todas as páginas: contagem de não lidas, painel com as recentes, atalho para `/notificacoes`.
- `app/stores/auth.ts` — login/logout, token, papel do usuário (`isAdmin`, `canBrowseProfiles`…).
- `app/stores/notifications.ts` — contagem de não lidas e as recentes, compartilhadas entre o sino e a página.
- `app/composables/useApi.ts` — `$fetch` com `Authorization` automático; em `401` faz logout e volta ao login.
- `app/middleware/auth.global.ts` — protege as rotas; colaborador não acessa Dashboard nem Funcionários.
- O frontend decide o botão Editar por `employee.user_role` + id do usuário atual; a API (`EmployeePolicy`) é a palavra final (403 tratado).
- Estrutura: `app/{pages,layouts,components,stores,composables,middleware,plugins,assets,utils}`.

Rodar isolado (sem Docker): `cd frontend && npm install && npm run dev`
(usa `http://localhost:3001` como API).

### Testes do frontend

**Vitest** + **@nuxt/test-utils** (ambiente `nuxt`, dá acesso a auto-imports/Pinia
nos testes) + **@vue/test-utils**. Config em `frontend/vitest.config.ts`.

```bash
docker compose exec frontend npm test          # roda uma vez
docker compose exec frontend npm run test:watch
```

| Arquivo | Cobre |
|---------|-------|
| `test/utils/format.test.ts` | funções puras de formatação (moeda, data, situação, categoria, tempo relativo) |
| `test/stores/auth.test.ts` | login/logout/hydrate, persistência no `localStorage`, getters de papel |
| `test/stores/notifications.test.ts` | `fetchUnread`/`markRead`/`markAllRead` |
| `test/components/StatCard.test.ts` | renderização do componente por props |

As chamadas de API dentro dos testes são mockadas com `registerEndpoint` (não bate na API real).

## Modelo de dados

Migrations em `backend/db/migrate/`, schema em `backend/db/schema.rb`.

| Tabela | Descrição | Relacionamentos |
|--------|-----------|-----------------|
| `users` | quem faz login (email, senha, `role_id`) | `belongs_to :role`, `has_one :employee`, `has_many :notifications` |
| `roles` | níveis de acesso (`admin`, `manager`, `employee`) | `has_many :permissions, through: :role_permissions`, `has_many :users` |
| `permissions` | ações do sistema (ex.: `employees.update`) | `has_many :roles, through: :role_permissions` |
| `role_permissions` | junção papel ↔ permissão | índice único `[role_id, permission_id]` |
| `departments` | departamentos da empresa | `has_many :employees` |
| `employees` | ficha do funcionário (nome, CPF, cargo, admissão, salário, situação…) | `belongs_to :department`, `belongs_to :user` (opcional), `has_paper_trail` |
| `notifications` | notificações por usuário | `belongs_to :user`, `belongs_to :notifiable` (polimórfico) |
| `versions` | histórico de alterações (gem `paper_trail`, colunas `object`/`object_changes` em `jsonb`) | referencia qualquer model auditado |

**Índices** (além dos de FK): únicos em `roles.name`, `permissions.name`,
`departments.name`, `employees.email`, `employees.document_number`,
`employees.user_id`; e de busca em `employees.employment_status`,
`employees.full_name`, `notifications [user_id, read_at]`.

**Validações** — nos models: presença/unicidade/formato de e-mail e CPF em
`Employee`, `terminated_on` posterior a `hired_on`, salário não-negativo,
unicidade de `name` em `Role`/`Permission`/`Department`, papel obrigatório em
`User` (com papel padrão `employee` atribuído automaticamente).

**Níveis de acesso** — dois mecanismos combinados: permissões do papel
(`user.can?("departments.manage")`) para o gate por recurso, e **Pundit**
(`app/policies/`) para as regras por registro do perfil de funcionário
(colaborador vê só o próprio; só admin edita; admin não edita outro admin).
`user.admin? / manager? / colaborador?`. Enums: `Employee#employment_status`
(`active`/`on_leave`/`terminated`) e `Notification#category`.

**Histórico** — `Employee` é versionado pelo `paper_trail`; o
`ApplicationController` grava o `whodunnit` a partir do usuário autenticado.

### Seeds

`docker compose up` (volume novo) roda `db:prepare` → migrations + `db:seed`.
Para rodar de novo (idempotente): `docker compose exec backend bin/rails db:seed`.

Cria 11 permissões, 3 papéis, 5 departamentos, **3 usuários**, **12 funcionários**
e 4 notificações. Cada usuário é vinculado a um perfil de funcionário.

| Usuário | Senha | Perfil | Perfil de funcionário vinculado |
|---------|-------|--------|--------------------------------|
| `admin@empresa.com` | `password123` | ADMIN | Ana Souza |
| `gestor@empresa.com` | `password123` | MANAGER | Gabriela Pinto |
| `funcionario@empresa.com` | `password123` | COLABORADOR | Henrique Dias |

## Variáveis de ambiente

Ver `.env.example`. Principais:

- `DATABASE_USER` / `DATABASE_PASSWORD` / `DATABASE_NAME` — credenciais do Postgres
- `DATABASE_PORT` / `FRONTEND_PORT` / `BACKEND_PORT` — portas publicadas no host
- `CORS_ORIGINS` — origens liberadas no CORS (`*` ou lista separada por vírgula)
- `NUXT_API_INTERNAL` — alvo do proxy `/api` do servidor Nuxt (padrão `http://backend:3000`)
- `UID` / `GID` — para os arquivos gerados pelo backend pertencerem ao seu usuário
- `JWT_SECRET_KEY` — chave de assinatura dos tokens (opcional em dev)
