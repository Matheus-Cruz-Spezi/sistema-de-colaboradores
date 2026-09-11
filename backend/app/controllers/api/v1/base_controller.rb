module Api
  module V1
    # Base de todos os controllers da API v1: autenticação, paginação,
    # ordenação segura, tratamento de erros e helpers de renderização.
    class BaseController < ApplicationController
      include Pagy::Method
      include ApiErrorHandling

      before_action :authenticate_user!

      private

      # RBAC: exige a permissão do papel do usuário atual.
      def authorize!(permission)
        return if current_user&.can?(permission)

        raise ApiError::Forbidden, "Acesso negado: requer a permissão '#{permission}'"
      end

      # Ordenação por whitelist (evita SQL injection via ?sort=).
      def apply_order(scope, allowed:, default:)
        column = allowed.include?(params[:sort].to_s) ? params[:sort] : default
        direction = params[:direction].to_s.casecmp("desc").zero? ? :desc : :asc
        scope.order(column => direction)
      end

      def pagination_meta(pagy)
        {
          page: pagy.page,
          per_page: pagy.limit,
          count: pagy.count,
          pages: pagy.pages,
          prev_page: pagy.previous,
          next_page: pagy.next
        }
      end

      # Coleção paginada: { data: [...], meta: { paginação } }
      def render_page(scope, with:)
        pagy, records = pagy(scope)
        render json: {
          data: with.new(records).serializable_hash,
          meta: pagination_meta(pagy)
        }
      end

      # Recurso único: { data: {...} }
      def render_resource(record, with:, status: :ok)
        render json: { data: with.new(record).serializable_hash }, status: status
      end
    end
  end
end
