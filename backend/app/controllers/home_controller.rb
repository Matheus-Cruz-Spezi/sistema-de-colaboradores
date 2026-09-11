class HomeController < ApplicationController
  def index
    render json: {
      app: "Meu Projeto Ruby - API",
      status: "ok",
      rails: Rails.version,
      ruby: RUBY_VERSION,
      environment: Rails.env,
      time: Time.current
    }
  end
end
