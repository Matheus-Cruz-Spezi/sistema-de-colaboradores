module Authenticatable
  extend ActiveSupport::Concern

  included do
    rescue_from JsonWebToken::InvalidToken, with: :render_unauthorized
  end

  private

  # Use como before_action nas rotas protegidas.
  def authenticate_user!
    current_user || render_unauthorized
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = resolve_user_from_token
  end

  # Payload do token da requisição atual (ou nil se não houver header).
  def decoded_token
    return @decoded_token if defined?(@decoded_token)

    header = request.headers["Authorization"].to_s
    token = header.start_with?("Bearer ") ? header.split(" ", 2).last : nil
    @decoded_token = token.present? ? JsonWebToken.decode(token) : nil
  end

  def resolve_user_from_token
    return nil if decoded_token.blank?
    return nil if JwtDenylist.exists?(jti: decoded_token[:jti])

    User.find_by(id: decoded_token[:sub])
  end

  def render_unauthorized(_error = nil)
    render json: { error: "Não autorizado" }, status: :unauthorized
  end
end
