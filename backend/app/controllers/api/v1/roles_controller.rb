module Api
  module V1
    class RolesController < BaseController
      # GET /api/v1/roles
      def index
        authorize! "roles.read"
        render_page(Role.includes(:permissions).order(:name), with: RoleSerializer)
      end

      # GET /api/v1/roles/:id
      def show
        authorize! "roles.read"
        render_resource(Role.includes(:permissions).find(params[:id]), with: RoleSerializer)
      end
    end
  end
end
