require "test_helper"

class RoleTest < ActiveSupport::TestCase
  test "nome é obrigatório e único" do
    assert_not Role.new.valid?
    assert_not Role.new(name: "admin").valid?
  end

  test "tem permissões através de role_permissions" do
    assert_includes roles(:manager).permissions, permissions(:departments_manage)
    assert roles(:manager).permission?("employees.read")
    assert_not roles(:manager).permission?("employees.update")
    assert_not roles(:employee).permission?("employees.update")
  end

  test "não pode ser removido com usuários vinculados" do
    User.create!(email: "a@empresa.com", password: "supersecret", role: roles(:manager))
    assert_not roles(:manager).destroy
    assert_includes roles(:manager).errors.attribute_names, :base
  end

  test "Role.default retorna o papel employee" do
    assert_equal roles(:employee), Role.default
  end
end
