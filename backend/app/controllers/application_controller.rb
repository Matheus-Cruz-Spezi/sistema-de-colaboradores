class ApplicationController < ActionController::API
  include Authenticatable
  include Pundit::Authorization
  include PaperTrail::Rails::Controller

  before_action :set_paper_trail_whodunnit

  private

  # Pundit usa o usuário autenticado via JWT.
  def pundit_user
    current_user
  end

  # Quem fez a alteração registrada no histórico (paper_trail).
  def user_for_paper_trail
    current_user&.id
  rescue JsonWebToken::InvalidToken
    nil
  end
end
