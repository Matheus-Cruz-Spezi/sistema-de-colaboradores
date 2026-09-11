class JwtDenylist < ApplicationRecord
  # Guarda o `jti` de tokens revogados (logout) até expirarem.
  scope :expired, -> { where(exp: ..Time.current) }
end
