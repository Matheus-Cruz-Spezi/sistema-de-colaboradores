module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!

      # GET /api/v1/me
      def me
        render json: UserSerializer.new(current_user).serializable_hash
      end
    end
  end
end
