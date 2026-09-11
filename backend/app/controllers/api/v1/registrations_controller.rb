module Api
  module V1
    class RegistrationsController < ApplicationController
      # POST /api/v1/signup
      def create
        user = User.new(user_params)

        if user.save
          render json: {
            user: UserSerializer.new(user).serializable_hash,
            token: JsonWebToken.encode({ sub: user.id })
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end
