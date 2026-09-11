module Api
  module V1
    class SessionsController < ApplicationController
      before_action :authenticate_user!, only: :destroy

      # POST /api/v1/login
      def create
        user = User.find_by(email: params[:email].to_s.strip.downcase)

        if user&.authenticate(params[:password])
          render json: {
            user: UserSerializer.new(user).serializable_hash,
            token: JsonWebToken.encode({ sub: user.id })
          }
        else
          render json: { error: "E-mail ou senha inválidos" }, status: :unauthorized
        end
      end

      # DELETE /api/v1/logout — revoga o token atual.
      def destroy
        JwtDenylist.find_or_create_by(jti: decoded_token[:jti]) do |entry|
          entry.exp = Time.at(decoded_token[:exp].to_i)
        end

        head :no_content
      end
    end
  end
end
