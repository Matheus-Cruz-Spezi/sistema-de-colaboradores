# Configuração de CORS para a API.
# CORS_ORIGINS aceita "*" ou uma lista separada por vírgula.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    configured = ENV.fetch("CORS_ORIGINS", "*")
    origins(configured == "*" ? "*" : configured.split(",").map(&:strip))

    resource "*",
      headers: :any,
      expose: %w[Authorization],
      methods: %i[get post put patch delete options head]
  end
end
