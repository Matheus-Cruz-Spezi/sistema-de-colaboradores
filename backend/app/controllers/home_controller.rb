class HomeController < ApplicationController
  def index
    render json: {
      app: "Sistema Colaborador - API",
      status: "ok",
      rails: Rails.version,
      ruby: RUBY_VERSION,
      environment: Rails.env,
      time: Time.current
    }
  end
end
