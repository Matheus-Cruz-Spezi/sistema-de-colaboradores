ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Helpers de teste em test/support/**.rb
Dir[Rails.root.join("test/support/**/*.rb")].each { |file| require file }

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Carrega todas as fixtures de test/fixtures/*.yml em cada teste.
    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  include AuthenticationHelper
end
