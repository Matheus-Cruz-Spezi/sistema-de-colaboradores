require "test_helper"

module Api
  class RolesApiTest < ActionDispatch::IntegrationTest
    setup { @user = create_user(permissions: %w[roles.read]) }

    test "lista papéis com suas permissões" do
      get "/api/v1/roles", headers: auth_headers_for(@user)
      assert_response :success

      manager = response.parsed_body["data"].find { |r| r["name"] == roles(:manager).name }
      assert_includes manager["permissions"], "departments.manage"
      assert_not_includes manager["permissions"], "employees.update"
    end

    test "lista permissões" do
      get "/api/v1/permissions", headers: auth_headers_for(@user)
      assert_response :success
      assert response.parsed_body["data"].any? { |p| p["name"] == "employees.read" }
    end

    test "exige roles.read" do
      get "/api/v1/roles", headers: auth_headers_for(create_user(permissions: []))
      assert_response :forbidden
    end
  end
end
