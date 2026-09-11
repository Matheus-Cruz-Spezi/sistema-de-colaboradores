module Api
  module V1
    # Perfil do próprio usuário autenticado: conta + ficha de funcionário (se houver).
    class ProfilesController < BaseController
      # GET /api/v1/profile
      def show
        render json: {
          user: UserSerializer.new(current_user).serializable_hash,
          employee: current_user.employee && EmployeeSerializer.new(current_user.employee).serializable_hash
        }
      end
    end
  end
end
