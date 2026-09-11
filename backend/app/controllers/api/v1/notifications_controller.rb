module Api
  module V1
    class NotificationsController < BaseController
      before_action :set_notification, only: %i[show destroy read]

      # GET /api/v1/notifications  (?unread=true &page= &per_page=)
      def index
        authorize! "notifications.read"

        scope = current_user.notifications.recent
        scope = scope.unread if params[:unread] == "true"

        render_page(scope, with: NotificationSerializer)
      end

      def show
        authorize! "notifications.read"
        render_resource(@notification, with: NotificationSerializer)
      end

      # PATCH /api/v1/notifications/:id/read
      def read
        authorize! "notifications.read"

        @notification.mark_as_read!
        render_resource(@notification, with: NotificationSerializer)
      end

      # PATCH /api/v1/notifications/read_all
      def read_all
        authorize! "notifications.read"

        current_user.notifications.unread.update_all(read_at: Time.current)
        head :no_content
      end

      def destroy
        authorize! "notifications.read"

        @notification.destroy!
        head :no_content
      end

      private

      # Sempre escopado ao usuário atual — ninguém vê notificação de outro.
      def set_notification
        @notification = current_user.notifications.find(params[:id])
      end
    end
  end
end
