require "test_helper"

# Etapa 4 — API protegida de acordo com o perfil do usuário.
#
#   COLABORADOR -> vê apenas o próprio perfil
#   MANAGER     -> vê todos os perfis
#   ADMIN       -> vê todos e edita os de colaborador e gestor (não os de outro admin)
module Api
  class ProfileAuthorizationTest < ActionDispatch::IntegrationTest
    setup do
      @tecnologia = departments(:tecnologia)

      @colaborador = colaborador_user
      @manager = manager_user
      @admin = admin_user
      @outro_admin = User.create!(email: "outro.admin@empresa.com", password: "supersecret", role: roles(:admin))

      @colaborador_profile = create_employee(user: @colaborador, full_name: "Perfil Colaborador")
      @manager_profile     = create_employee(user: @manager,     full_name: "Perfil Gestor")
      @admin_profile       = create_employee(user: @admin,       full_name: "Perfil Admin")
      @outro_admin_profile = create_employee(user: @outro_admin, full_name: "Perfil Outro Admin")
      @outro_colaborador   = create_employee(full_name: "Outro Colaborador")
    end

    # ---------- COLABORADOR ----------

    test "colaborador vê apenas o próprio perfil na listagem" do
      get "/api/v1/employees", headers: auth_headers_for(@colaborador)
      assert_response :success

      ids = response.parsed_body["data"].map { |e| e["id"] }
      assert_equal [ @colaborador_profile.id ], ids
    end

    test "colaborador acessa o próprio perfil" do
      get "/api/v1/employees/#{@colaborador_profile.id}", headers: auth_headers_for(@colaborador)
      assert_response :success
    end

    test "colaborador NÃO acessa o perfil de outra pessoa" do
      get "/api/v1/employees/#{@outro_colaborador.id}", headers: auth_headers_for(@colaborador)
      assert_response :forbidden
    end

    test "colaborador NÃO edita nem o próprio perfil" do
      patch "/api/v1/employees/#{@colaborador_profile.id}",
            headers: auth_headers_for(@colaborador),
            params: { employee: { job_title: "Auto-promoção" } }
      assert_response :forbidden
    end

    test "colaborador NÃO cria funcionários" do
      post "/api/v1/employees", headers: auth_headers_for(@colaborador), params: {
        employee: { full_name: "X", email: "x@e.com", document_number: "12312312312",
                    job_title: "Y", department_id: @tecnologia.id, hired_on: "2025-01-01" }
      }
      assert_response :forbidden
    end

    # ---------- MANAGER ----------

    test "manager vê todos os perfis" do
      get "/api/v1/employees", headers: auth_headers_for(@manager)
      assert_response :success
      assert_equal Employee.count, response.parsed_body["meta"]["count"]
    end

    test "manager acessa o perfil de qualquer pessoa" do
      get "/api/v1/employees/#{@outro_colaborador.id}", headers: auth_headers_for(@manager)
      assert_response :success
    end

    test "manager NÃO edita perfis" do
      patch "/api/v1/employees/#{@outro_colaborador.id}",
            headers: auth_headers_for(@manager),
            params: { employee: { job_title: "Novo" } }
      assert_response :forbidden
    end

    # ---------- ADMIN ----------

    test "admin vê todos os perfis" do
      get "/api/v1/employees", headers: auth_headers_for(@admin)
      assert_response :success
      assert_equal Employee.count, response.parsed_body["meta"]["count"]
    end

    test "admin edita o perfil de um colaborador" do
      patch "/api/v1/employees/#{@colaborador_profile.id}",
            headers: auth_headers_for(@admin),
            params: { employee: { job_title: "Analista Sênior" } }
      assert_response :success
      assert_equal "Analista Sênior", @colaborador_profile.reload.job_title
    end

    test "admin edita o perfil de um gestor" do
      patch "/api/v1/employees/#{@manager_profile.id}",
            headers: auth_headers_for(@admin),
            params: { employee: { job_title: "Head de Área" } }
      assert_response :success
    end

    test "admin NÃO edita o próprio perfil" do
      patch "/api/v1/employees/#{@admin_profile.id}",
            headers: auth_headers_for(@admin),
            params: { employee: { phone: "11912345678" } }
      assert_response :forbidden
    end

    test "admin NÃO edita o perfil de outro admin" do
      patch "/api/v1/employees/#{@outro_admin_profile.id}",
            headers: auth_headers_for(@admin),
            params: { employee: { job_title: "Qualquer" } }
      assert_response :forbidden
    end

    test "admin edita funcionário sem usuário vinculado" do
      patch "/api/v1/employees/#{@outro_colaborador.id}",
            headers: auth_headers_for(@admin),
            params: { employee: { job_title: "Atualizado" } }
      assert_response :success
    end

    test "admin NÃO remove o perfil de outro admin" do
      delete "/api/v1/employees/#{@outro_admin_profile.id}", headers: auth_headers_for(@admin)
      assert_response :forbidden
    end

    # ---------- histórico ----------

    test "colaborador vê o histórico do próprio perfil, não o de outros" do
      get "/api/v1/employees/#{@colaborador_profile.id}/history", headers: auth_headers_for(@colaborador)
      assert_response :success

      get "/api/v1/employees/#{@outro_colaborador.id}/history", headers: auth_headers_for(@colaborador)
      assert_response :forbidden
    end

    private

    def create_employee(**overrides)
      Employee.create!({
        full_name: "Fulano #{SecureRandom.hex(3)}",
        email: "#{SecureRandom.hex(4)}@empresa.com",
        document_number: SecureRandom.random_number(10**11).to_s.rjust(11, "0"),
        job_title: "Analista",
        department: @tecnologia,
        hired_on: Date.new(2023, 1, 1)
      }.merge(overrides))
    end
  end
end
