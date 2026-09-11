require "test_helper"

module Api
  class NotificationsApiTest < ActionDispatch::IntegrationTest
    setup do
      @user = create_user(permissions: %w[notifications.read])
      @other = create_user(permissions: %w[notifications.read])
      @n1 = Notification.create!(user: @user, title: "Primeira")
      @n2 = Notification.create!(user: @user, title: "Segunda", read_at: Time.current)
      Notification.create!(user: @other, title: "De outro usuário")
    end

    test "index mostra só as notificações do usuário atual" do
      get "/api/v1/notifications", headers: auth_headers_for(@user)
      assert_response :success
      titles = response.parsed_body["data"].map { |n| n["title"] }
      assert_equal %w[Segunda Primeira], titles
      assert_not_includes titles, "De outro usuário"
    end

    test "filtro unread=true" do
      get "/api/v1/notifications", params: { unread: "true" }, headers: auth_headers_for(@user)
      assert_equal [ "Primeira" ], response.parsed_body["data"].map { |n| n["title"] }
    end

    test "marcar como lida" do
      patch "/api/v1/notifications/#{@n1.id}/read", headers: auth_headers_for(@user)
      assert_response :success
      assert @n1.reload.read?
      assert response.parsed_body.dig("data", "read")
    end

    test "marcar todas como lidas" do
      patch "/api/v1/notifications/read_all", headers: auth_headers_for(@user)
      assert_response :no_content
      assert_equal 0, @user.notifications.unread.count
    end

    test "não acessa notificação de outro usuário" do
      other_notification = @other.notifications.first
      get "/api/v1/notifications/#{other_notification.id}", headers: auth_headers_for(@user)
      assert_response :not_found
    end

    test "exige autenticação" do
      get "/api/v1/notifications"
      assert_response :unauthorized
    end
  end
end
