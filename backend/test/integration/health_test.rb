require "test_helper"

class HealthTest < ActionDispatch::IntegrationTest
  test "GET /api/v1/health reporta a API e o banco" do
    User.create!(email: "h@example.com", password: "supersecret")

    get "/api/v1/health"

    assert_response :success
    body = response.parsed_body
    assert_equal "ok", body["status"]
    assert_equal "connected", body["database"]
    assert_equal 1, body["users_count"]
  end
end
