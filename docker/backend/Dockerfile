# Backend — API Ruby on Rails 8
# Contexto de build: ./backend
FROM ruby:3.3-slim

ENV LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

# build-essential/libpq-dev: gems nativas + cliente PostgreSQL (gem "pg")
# git/curl: dependências de gems e healthcheck/debug
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      git \
      curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instala as gems primeiro para aproveitar o cache de camadas.
COPY Gemfile Gemfile.lock* ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
