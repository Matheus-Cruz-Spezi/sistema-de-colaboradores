# Autorização por perfil (Etapa 4):
#
#   COLABORADOR (employee) — vê apenas o próprio perfil
#   MANAGER                — vê todos os perfis (não edita)
#   ADMIN                  — vê todos; edita perfis de colaborador e gestor.
#                            NÃO edita o próprio perfil nem o de outro admin.
class EmployeePolicy < ApplicationPolicy
  def index?
    user.can?("employees.read")
  end

  def show?
    user.can?("employees.read") && (view_all? || owner?)
  end

  # Quem pode ver o perfil pode ver o histórico dele.
  def history?
    show?
  end

  def create?
    user.admin? && user.can?("employees.create")
  end

  # Admin edita perfis de colaborador e gestor — nunca o próprio nem o de outro admin.
  # (`target_not_admin?` já exclui o próprio, pois o próprio usuário é admin.)
  def update?
    user.admin? && user.can?("employees.update") && target_not_admin?
  end

  def destroy?
    user.admin? && user.can?("employees.destroy") && target_not_admin?
  end

  private

  def view_all?
    user.admin? || user.manager?
  end

  def owner?
    record.respond_to?(:user_id) && record.user_id == user.id
  end

  # Não permite mexer no perfil de um usuário ADMIN.
  def target_not_admin?
    record.user.nil? || !record.user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user.can?("employees.read")

      if user.admin? || user.manager?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
