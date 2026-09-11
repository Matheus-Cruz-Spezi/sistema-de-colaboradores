module Api
  module V1
    class HealthController < ApplicationController
      # GET /api/v1/health
      # Verifica a cadeia Rails -> PostgreSQL para o frontend.
      def show
        ActiveRecord::Base.connection.execute("SELECT 1")

        render json: {
          status: "ok",
          service: "rails-api",
          database: "connected",
          users_count: User.count,
          rails: Rails.version,
          time: Time.current
        }
      rescue ActiveRecord::ActiveRecordError => e
        render json: { status: "error", database: "unavailable", detail: e.message },
               status: :service_unavailable
      end
    end
  end
end
