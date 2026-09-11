require "test_helper"

module Api
  class ProfileEndpointTest < ActionDispatch::IntegrationTest
    test "retorna a conta e a ficha de funcionário vinculada" do
      user = colaborador_user
      employee = Employee.create!(
        full_name: "Perfil Teste", email: "perfil.teste@empresa.com", document_number: "74185296300",
        job_title: "Analista", department: departments(:tecnologia), hired_on: Date.new(2024, 1, 1), user:
      )

      get "/api/v1/profile", headers: auth_headers_for(user)

      assert_response :success
      assert_equal user.email, response.parsed_body.dig("user", "email")
      assert_equal employee.id, response.parsed_body.dig("employee", "id")
    end

    test "employee é nulo quando o usuário não tem ficha" do
      get "/api/v1/profile", headers: auth_headers_for(colaborador_user)
      assert_response :success
      assert_nil response.parsed_body["employee"]
    end

    test "exige autenticação" do
      get "/api/v1/profile"
      assert_response :unauthorized
    end
  end
end
