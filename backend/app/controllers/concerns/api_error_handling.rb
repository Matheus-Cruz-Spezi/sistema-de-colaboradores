# Traduz exceções em respostas JSON com o status HTTP apropriado.
module ApiErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ApiError::Forbidden,                with: :render_forbidden
    rescue_from Pundit::NotAuthorizedError,         with: :render_forbidden_policy
    rescue_from ActiveRecord::RecordNotFound,       with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid,        with: :render_unprocessable
    rescue_from ActiveRecord::RecordNotDestroyed,   with: :render_conflict
    rescue_from ActionController::ParameterMissing, with: :render_bad_request
  end

  private

  def render_forbidden(exception)
    render json: { error: exception.message }, status: :forbidden
  end

  def render_forbidden_policy(_exception)
    render json: { error: "Seu perfil de acesso não permite esta ação" }, status: :forbidden
  end

  def render_not_found(_exception)
    render json: { error: "Recurso não encontrado" }, status: :not_found
  end

  def render_unprocessable(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_conflict(exception)
    messages = exception.record.errors.full_messages.presence ||
               [ "Não é possível remover: há registros associados" ]
    render json: { errors: messages }, status: :unprocessable_entity
  end

  def render_bad_request(exception)
    render json: { error: "Parâmetro obrigatório ausente: #{exception.param}" }, status: :bad_request
  end
end
