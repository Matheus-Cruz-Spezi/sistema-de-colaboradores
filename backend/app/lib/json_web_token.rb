class JsonWebToken
  ALGORITHM = "HS256".freeze
  DEFAULT_EXPIRATION = 24.hours

  # Erro único para qualquer falha de decodificação (token inválido, expirado, etc).
  class InvalidToken < StandardError; end

  class << self
    def encode(payload, exp: DEFAULT_EXPIRATION.from_now)
      payload = payload.dup
      payload[:exp] = exp.to_i
      payload[:jti] ||= SecureRandom.uuid
      JWT.encode(payload, secret_key, ALGORITHM)
    end

    def decode(token)
      body, = JWT.decode(token, secret_key, true, algorithm: ALGORITHM)
      body.with_indifferent_access
    rescue JWT::DecodeError => e
      raise InvalidToken, e.message
    end

    private

    def secret_key
      ENV.fetch("JWT_SECRET_KEY") { Rails.application.secret_key_base }
    end
  end
end
