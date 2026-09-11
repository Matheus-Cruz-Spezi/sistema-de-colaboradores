# Frontend — Nuxt 4 (Vue 3)
# Contexto de build: ./frontend
FROM node:22-slim

ENV NODE_ENV=development

WORKDIR /app

# Instala as dependências primeiro para aproveitar o cache de camadas.
COPY package.json package-lock.json* ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]
