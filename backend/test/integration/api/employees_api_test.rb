require "test_helper"

module Api
  class EmployeesApiTest < ActionDispatch::IntegrationTest
    setup do
      @admin = admin_user
      @tecnologia = departments(:tecnologia)
    end

    # ---- autenticação / autorização ----

    test "index exige autenticação" do
      get "/api/v1/employees"
      assert_response :unauthorized
    end

    test "index sem permissão de leitura retorna 403" do
      user = create_user(permissions: [])
      get "/api/v1/employees", headers: auth_headers_for(user)
      assert_response :forbidden
      assert response.parsed_body["error"].present?
    end

    # ---- listagem / envelope / paginação ----

    test "index retorna data + meta de paginação" do
      get "/api/v1/employees", headers: auth_headers_for(@admin)
      assert_response :success

      body = response.parsed_body
      assert_kind_of Array, body["data"]
      assert_equal Employee.count, body["meta"]["count"]
      assert_equal 20, body["meta"]["per_page"]
      assert body["data"].first.key?("full_name")
      assert body["data"].first["department"].is_a?(Hash)
    end

    test "index pagina com page e per_page" do
      3.times { |i| create_employee(full_name: "Zzz #{i}") }

      get "/api/v1/employees", params: { per_page: 2, page: 1 }, headers: auth_headers_for(@admin)
      assert_response :success
      assert_equal 2, response.parsed_body["data"].size
      assert_equal 2, response.parsed_body["meta"]["per_page"]
      assert_equal 2, response.parsed_body["meta"]["next_page"]
    end

    test "per_page respeita o teto de 100" do
      get "/api/v1/employees", params: { per_page: 9999 }, headers: auth_headers_for(@admin)
      assert_equal 100, response.parsed_body["meta"]["per_page"]
    end

    # ---- filtros ----

    test "filtra por situação" do
      get "/api/v1/employees", params: { status: "on_leave" }, headers: auth_headers_for(@admin)
      names = response.parsed_body["data"].map { |e| e["full_name"] }
      assert_includes names, employees(:bruno).full_name
      assert_not_includes names, employees(:ana).full_name
    end

    test "filtra por departamento" do
      get "/api/v1/employees", params: { department_id: @tecnologia.id }, headers: auth_headers_for(@admin)
      department_ids = response.parsed_body["data"].map { |e| e["department_id"] }.uniq
      assert_equal [ @tecnologia.id ], department_ids
    end

    test "busca por nome/cargo/email com q" do
      get "/api/v1/employees", params: { q: "ana.souza@empresa" }, headers: auth_headers_for(@admin)
      assert_equal [ employees(:ana).full_name ], response.parsed_body["data"].map { |e| e["full_name"] }
    end

    test "status inválido é ignorado (retorna todos)" do
      get "/api/v1/employees", params: { status: "qualquer" }, headers: auth_headers_for(@admin)
      assert_response :success
      assert_equal Employee.count, response.parsed_body["meta"]["count"]
    end

    # ---- ordenação ----

    test "ordena por coluna da whitelist" do
      get "/api/v1/employees", params: { sort: "hired_on", direction: "asc" }, headers: auth_headers_for(@admin)
      dates = response.parsed_body["data"].map { |e| e["hired_on"] }
      assert_equal dates.sort, dates
    end

    test "sort fora da whitelist cai no padrão (full_name)" do
      get "/api/v1/employees", params: { sort: "salary; DROP TABLE" }, headers: auth_headers_for(@admin)
      assert_response :success
      names = response.parsed_body["data"].map { |e| e["full_name"] }
      assert_equal names.sort, names
    end

    # ---- show ----

    test "show retorna o funcionário" do
      get "/api/v1/employees/#{employees(:ana).id}", headers: auth_headers_for(@admin)
      assert_response :success
      assert_equal employees(:ana).email, response.parsed_body.dig("data", "email")
    end

    test "serializa o papel do usuário vinculado (user_role) para o frontend" do
      colaborador = colaborador_user
      linked = create_employee(user: colaborador)

      get "/api/v1/employees/#{linked.id}", headers: auth_headers_for(@admin)
      assert_equal "employee", response.parsed_body.dig("data", "user_role")

      get "/api/v1/employees/#{employees(:ana).id}", headers: auth_headers_for(@admin)
      assert_nil response.parsed_body.dig("data", "user_role")
    end

    test "show inexistente retorna 404" do
      get "/api/v1/employees/0", headers: auth_headers_for(@admin)
      assert_response :not_found
    end

    # ---- create ----

    test "create com dados válidos retorna 201" do
      assert_difference -> { Employee.count }, 1 do
        post "/api/v1/employees", headers: auth_headers_for(@admin), params: {
          employee: {
            full_name: "Novo Colaborador", email: "novo.colab@empresa.com",
            document_number: "32165498700", job_title: "Analista",
            department_id: @tecnologia.id, hired_on: "2025-02-01", salary: 5000
          }
        }
      end
      assert_response :created
      assert_equal "Novo Colaborador", response.parsed_body.dig("data", "full_name")
    end

    test "create com dados inválidos retorna 422 e mensagens" do
      post "/api/v1/employees", headers: auth_headers_for(@admin), params: {
        employee: { full_name: "", email: "x", document_number: "1", job_title: "", department_id: @tecnologia.id }
      }
      assert_response :unprocessable_entity
      assert response.parsed_body["errors"].any?
    end

    test "create sem body retorna 400" do
      post "/api/v1/employees", headers: auth_headers_for(@admin)
      assert_response :bad_request
    end

    test "create sem permissão retorna 403" do
      user = create_user(permissions: %w[employees.read])
      post "/api/v1/employees", headers: auth_headers_for(user), params: {
        employee: { full_name: "X Y", email: "xy@empresa.com", document_number: "11122233399",
                    job_title: "Z", department_id: @tecnologia.id, hired_on: "2025-01-01" }
      }
      assert_response :forbidden
    end

    # ---- update / destroy ----

    test "update altera o funcionário" do
      patch "/api/v1/employees/#{employees(:ana).id}", headers: auth_headers_for(@admin),
            params: { employee: { job_title: "Staff Engineer" } }
      assert_response :success
      assert_equal "Staff Engineer", employees(:ana).reload.job_title
    end

    test "destroy remove o funcionário" do
      employee = create_employee
      assert_difference -> { Employee.count }, -1 do
        delete "/api/v1/employees/#{employee.id}", headers: auth_headers_for(@admin)
      end
      assert_response :no_content
    end

    # ---- history ----

    test "history lista as versões do paper_trail" do
      employee = create_employee
      employee.update!(job_title: "Promovido")

      get "/api/v1/employees/#{employee.id}/history", headers: auth_headers_for(@admin)
      assert_response :success
      events = response.parsed_body["data"].map { |v| v["event"] }
      assert_includes events, "create"
      assert_includes events, "update"
    end

    private

    def create_employee(**overrides)
      Employee.create!({
        full_name: "Fulano #{SecureRandom.hex(3)}",
        email: "#{SecureRandom.hex(4)}@empresa.com",
        document_number: SecureRandom.random_number(10**11).to_s.rjust(11, "0"),
        job_title: "Analista",
        department: departments(:tecnologia),
        hired_on: Date.new(2023, 1, 1)
      }.merge(overrides))
    end
  end
end
