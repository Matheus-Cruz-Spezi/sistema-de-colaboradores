module ApiError
  class Base < StandardError; end

  # Usuário autenticado, mas sem a permissão exigida pela ação.
  class Forbidden < Base; end
end
