require "test_helper"

module Api
  class DepartmentsApiTest < ActionDispatch::IntegrationTest
    setup { @admin = admin_user }

    test "index retorna departamentos com contagem de funcionários" do
      get "/api/v1/departments", headers: auth_headers_for(@admin)
      assert_response :success

      tecnologia = response.parsed_body["data"].find { |d| d["name"] == "Tecnologia" }
      assert_equal departments(:tecnologia).employees.count, tecnologia["employees_count"]
    end

    test "index exige departments.read" do
      get "/api/v1/departments", headers: auth_headers_for(create_user(permissions: []))
      assert_response :forbidden
    end

    test "create com departments.manage" do
      assert_difference -> { Department.count }, 1 do
        post "/api/v1/departments", headers: auth_headers_for(@admin),
             params: { department: { name: "Jurídico", description: "Contratos" } }
      end
      assert_response :created
    end

    test "create sem permissão retorna 403" do
      user = create_user(permissions: %w[departments.read])
      post "/api/v1/departments", headers: auth_headers_for(user), params: { department: { name: "X" } }
      assert_response :forbidden
    end

    test "create com nome duplicado retorna 422" do
      post "/api/v1/departments", headers: auth_headers_for(@admin),
           params: { department: { name: departments(:tecnologia).name } }
      assert_response :unprocessable_entity
    end

    test "update altera o departamento" do
      patch "/api/v1/departments/#{departments(:tecnologia).id}", headers: auth_headers_for(@admin),
            params: { department: { description: "Nova descrição" } }
      assert_response :success
      assert_equal "Nova descrição", departments(:tecnologia).reload.description
    end

    test "destroy com funcionários vinculados retorna 422" do
      delete "/api/v1/departments/#{departments(:tecnologia).id}", headers: auth_headers_for(@admin)
      assert_response :unprocessable_entity
      assert response.parsed_body["errors"].any?
    end

    test "destroy de departamento vazio retorna 204" do
      department = Department.create!(name: "Vazio")
      delete "/api/v1/departments/#{department.id}", headers: auth_headers_for(@admin)
      assert_response :no_content
    end
  end
end
