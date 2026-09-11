require "test_helper"

module Api
  class DashboardApiTest < ActionDispatch::IntegrationTest
    test "retorna as métricas agregadas" do
      admin = admin_user
      get "/api/v1/dashboard", headers: auth_headers_for(admin)
      assert_response :success

      data = response.parsed_body["data"]
      assert_equal Employee.count, data["employees"]["total"]
      assert_equal Employee.on_leave.count, data["employees"]["on_leave"]
      assert data.key?("payroll")
      assert data["by_department"].is_a?(Array)
      assert data["recent_hires"].is_a?(Array)
      assert data.dig("notifications", "unread").is_a?(Integer)
    end

    test "exige a permissão dashboard.view" do
      user = create_user(permissions: %w[employees.read])
      get "/api/v1/dashboard", headers: auth_headers_for(user)
      assert_response :forbidden
    end

    test "exige autenticação" do
      get "/api/v1/dashboard"
      assert_response :unauthorized
    end
  end
end
