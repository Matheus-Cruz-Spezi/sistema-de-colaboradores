module Api
  module V1
    class PermissionsController < BaseController
      # GET /api/v1/permissions
      def index
        authorize! "roles.read"
        render_page(Permission.order(:name), with: PermissionSerializer)
      end
    end
  end
end
