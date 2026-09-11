require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  test "signup cria o usuário e devolve um token" do
    assert_difference -> { User.count }, 1 do
      post "/api/v1/signup", params: { user: { email: "Alice@Example.com", password: "supersecret" } }
    end

    assert_response :created
    assert response.parsed_body["token"].present?
    assert_equal "alice@example.com", response.parsed_body.dig("user", "email")
    assert_nil response.parsed_body.dig("user", "password_digest")
  end

  test "signup rejeita dados inválidos" do
    assert_no_difference -> { User.count } do
      post "/api/v1/signup", params: { user: { email: "invalido", password: "curta" } }
    end

    assert_response :unprocessable_entity
    assert response.parsed_body["errors"].any?
  end

  test "signup rejeita e-mail duplicado" do
    User.create!(email: "dup@example.com", password: "supersecret")

    post "/api/v1/signup", params: { user: { email: "dup@example.com", password: "supersecret" } }

    assert_response :unprocessable_entity
  end

  test "login com credenciais válidas devolve um token" do
    User.create!(email: "bob@example.com", password: "supersecret")

    post "/api/v1/login", params: { email: "BOB@example.com", password: "supersecret" }

    assert_response :success
    assert response.parsed_body["token"].present?
  end

  test "login cria e devolve uma notificação de boas-vindas não lida" do
    user = User.create!(email: "erin@example.com", password: "supersecret")

    assert_difference -> { user.notifications.count }, 1 do
      post "/api/v1/login", params: { email: "erin@example.com", password: "supersecret" }
    end

    assert_response :success
    notification = response.parsed_body["notification"]
    assert_match(/Bem-vindo/, notification["title"])
    assert_equal false, notification["read"]
  end

  test "login com senha errada é 401" do
    User.create!(email: "bob@example.com", password: "supersecret")

    post "/api/v1/login", params: { email: "bob@example.com", password: "errada" }

    assert_response :unauthorized
  end

  test "GET /me exige autenticação" do
    get "/api/v1/me"

    assert_response :unauthorized
  end

  test "GET /me devolve o usuário atual com token válido" do
    user = User.create!(email: "carol@example.com", password: "supersecret")
    token = JsonWebToken.encode({ sub: user.id })

    get "/api/v1/me", headers: { "Authorization" => "Bearer #{token}" }

    assert_response :success
    assert_equal "carol@example.com", response.parsed_body["email"]
  end

  test "GET /me rejeita token malformado" do
    get "/api/v1/me", headers: { "Authorization" => "Bearer nao-e-um-token" }

    assert_response :unauthorized
  end

  test "logout revoga o token atual" do
    user = User.create!(email: "dave@example.com", password: "supersecret")
    token = JsonWebToken.encode({ sub: user.id })
    auth = { "Authorization" => "Bearer #{token}" }

    delete "/api/v1/logout", headers: auth
    assert_response :no_content

    get "/api/v1/me", headers: auth
    assert_response :unauthorized
  end
end
