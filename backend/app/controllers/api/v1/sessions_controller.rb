module Api
  module V1
    class SessionsController < ApplicationController
      before_action :authenticate_user!, only: :destroy

      # POST /api/v1/login
      def create
        user = User.find_by(email: params[:email].to_s.strip.downcase)

        if user&.authenticate(params[:password])
          notification = welcome_notification_for(user)

          render json: {
            user: UserSerializer.new(user).serializable_hash,
            token: JsonWebToken.encode({ sub: user.id }),
            notification: NotificationSerializer.new(notification).serializable_hash
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

      private

      # Criada a cada login (de propósito): serve como "sinal vivo" de que o
      # sistema de notificações está funcionando — aparece na hora como toast
      # e continua na caixa de não lidas até o usuário marcar como lida.
      def welcome_notification_for(user)
        now = Time.current.strftime("%d/%m/%Y às %H:%M")

        user.notifications.create!(
          title: "Bem-vindo(a) de volta, #{user.display_name}!",
          body: "Login realizado em #{now}. Esta notificação confirma que o sistema está funcionando normalmente.",
          category: :success
        )
      end
    end
  end
end
