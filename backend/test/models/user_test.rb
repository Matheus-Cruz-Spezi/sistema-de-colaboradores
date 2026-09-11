require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "novo usuário recebe o papel padrão (employee)" do
    user = User.create!(email: "sem.papel@empresa.com", password: "supersecret")
    assert_equal Role::EMPLOYEE, user.role.name
  end

  test "papel explícito é respeitado" do
    user = User.create!(email: "chefe@empresa.com", password: "supersecret", role: roles(:admin))
    assert_equal Role::ADMIN, user.role.name
  end

  test "can? reflete as permissões do papel" do
    manager = User.create!(email: "m@empresa.com", password: "supersecret", role: roles(:manager))
    assert manager.can?("employees.read")
    assert manager.can?("departments.manage")
    assert_not manager.can?("employees.update")
  end

  test "predicados de perfil" do
    assert User.new(role: roles(:admin)).admin?
    assert User.new(role: roles(:manager)).manager?
    assert User.new(role: roles(:employee)).colaborador?
    assert_not User.new(role: roles(:employee)).admin?
  end

  test "as_json expõe o papel e nunca o password_digest" do
    json = users_admin.as_json
    assert_equal "admin", json["role"]
    assert_not json.key?("password_digest")
  end

  test "um usuário pode estar vinculado a um funcionário" do
    user = User.create!(email: "vinculo@empresa.com", password: "supersecret")
    employee = Employee.create!(
      full_name: "Pessoa Vinculada", email: "vinc@empresa.com", document_number: "98765432100",
      job_title: "Analista", department: departments(:tecnologia), hired_on: Date.today, user:
    )
    assert_equal employee, user.reload.employee
  end

  private

  def users_admin
    User.create!(email: "admin.json@empresa.com", password: "supersecret", role: roles(:admin))
  end
end
