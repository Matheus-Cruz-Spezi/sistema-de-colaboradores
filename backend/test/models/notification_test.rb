require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "notif@empresa.com", password: "supersecret")
  end

  test "exige título e usuário" do
    assert_not Notification.new.valid?
  end

  test "pode referenciar um registro (notifiable polimórfico)" do
    notification = Notification.create!(user: @user, title: "Cargo alterado", notifiable: employees(:ana))
    assert_equal employees(:ana), notification.notifiable
    assert_includes employees(:ana).notifications, notification
  end

  test "mark_as_read! e scopes unread/read" do
    n = Notification.create!(user: @user, title: "Nova")
    assert_includes Notification.unread, n

    n.mark_as_read!
    assert n.read?
    assert_includes Notification.read, n
  end
end
