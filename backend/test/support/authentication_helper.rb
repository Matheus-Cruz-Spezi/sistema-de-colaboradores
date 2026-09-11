module AuthenticationHelper
  # Cabeçalho Authorization com um JWT válido para o usuário.
  def auth_headers_for(user)
    { "Authorization" => "Bearer #{JsonWebToken.encode({ sub: user.id })}" }
  end

  # Usuário com um dos três perfis reais (fixtures roles.yml + role_permissions.yml).
  def admin_user
    @admin_user ||= build_user(roles(:admin))
  end

  def manager_user
    @manager_user ||= build_user(roles(:manager))
  end

  def colaborador_user
    @colaborador_user ||= build_user(roles(:employee))
  end

  # Usuário com um papel avulso e exatamente as permissões pedidas
  # (para testar o gate de permissão sem herdar um dos perfis nomeados).
  def create_user(permissions: [], role_name: "role")
    role = Role.create!(name: "#{role_name}-#{SecureRandom.hex(4)}")
    Array(permissions).each do |permission_name|
      role.permissions << Permission.find_or_create_by!(name: permission_name)
    end
    build_user(role)
  end

  private

  def build_user(role)
    User.create!(email: "#{SecureRandom.hex(6)}@empresa.com", password: "supersecret", role:)
  end
end
