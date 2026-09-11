# Seeds idempotentes — podem rodar várias vezes sem duplicar dados.
#   docker compose exec backend bin/rails db:seed

puts "== Permissions =="
PERMISSIONS = {
  "dashboard.view"      => "Ver o dashboard",
  "employees.read"      => "Consultar funcionários",
  "employees.create"    => "Cadastrar funcionários",
  "employees.update"    => "Editar funcionários",
  "employees.destroy"   => "Remover funcionários",
  "employees.history"   => "Ver o histórico de alterações",
  "departments.read"    => "Consultar departamentos",
  "departments.manage"  => "Gerenciar departamentos",
  "notifications.read"  => "Ver notificações",
  "roles.read"          => "Consultar papéis e permissões",
  "users.manage"        => "Gerenciar usuários e níveis de acesso"
}.freeze

PERMISSIONS.each do |name, description|
  Permission.find_or_create_by!(name:) { |p| p.description = description }
end

puts "== Roles + permissões =="
ROLES = {
  Role::ADMIN => {
    description: "Acesso total ao sistema",
    permissions: :all
  },
  Role::MANAGER => {
    # Vê todos os perfis, mas não cria/edita funcionários (só o admin edita).
    description: "Visualiza todos os perfis; gerencia departamentos",
    permissions: %w[dashboard.view employees.read employees.history
                    departments.read departments.manage
                    notifications.read roles.read]
  },
  Role::EMPLOYEE => {
    # Colaborador: vê apenas o próprio perfil (sem dashboard gerencial).
    description: "Acesso básico; vê apenas o próprio perfil",
    permissions: %w[employees.read departments.read notifications.read]
  }
}.freeze

ROLES.each do |name, config|
  role = Role.find_or_create_by!(name:) { |r| r.description = config[:description] }
  role.permissions =
    config[:permissions] == :all ? Permission.all : Permission.where(name: config[:permissions])
end

puts "== Departamentos =="
DEPARTMENTS = {
  "Tecnologia"       => "Desenvolvimento, infraestrutura e suporte",
  "Recursos Humanos" => "Recrutamento, folha de pagamento e benefícios",
  "Financeiro"       => "Contas a pagar/receber e controladoria",
  "Comercial"        => "Vendas e relacionamento com clientes",
  "Operações"        => "Logística e processos internos"
}.freeze

DEPARTMENTS.each do |name, description|
  Department.find_or_create_by!(name:) { |d| d.description = description }
end

puts "== Usuários =="
admin = User.find_or_create_by!(email: "admin@empresa.com") do |u|
  u.password = "password123"
  u.role = Role.find_by!(name: Role::ADMIN)
end

manager = User.find_or_create_by!(email: "gestor@empresa.com") do |u|
  u.password = "password123"
  u.role = Role.find_by!(name: Role::MANAGER)
end

colaborador = User.find_or_create_by!(email: "funcionario@empresa.com") do |u|
  u.password = "password123"
  u.role = Role.find_by!(name: Role::EMPLOYEE)
end

puts "== Funcionários =="
EMPLOYEES = [
  { full_name: "Ana Souza",      email: "ana.souza@empresa.com",      document_number: "11111111111", job_title: "Desenvolvedora Backend", department: "Tecnologia",       hired_on: "2022-03-01", salary: 9_500,  birth_date: "1993-06-12", phone: "11999990001", status: :active },
  { full_name: "Bruno Lima",     email: "bruno.lima@empresa.com",     document_number: "22222222222", job_title: "Analista de RH",         department: "Recursos Humanos", hired_on: "2021-08-15", salary: 7_200,  birth_date: "1990-01-30", phone: "11999990002", status: :active },
  { full_name: "Carla Nunes",    email: "carla.nunes@empresa.com",    document_number: "33333333333", job_title: "Analista Financeiro",     department: "Financeiro",       hired_on: "2020-02-10", salary: 8_100,  birth_date: "1988-11-05", phone: "11999990003", status: :active },
  { full_name: "Diego Alves",    email: "diego.alves@empresa.com",    document_number: "44444444444", job_title: "Executivo de Vendas",     department: "Comercial",        hired_on: "2023-05-02", salary: 6_800,  birth_date: "1995-09-21", phone: "11999990004", status: :active },
  { full_name: "Eduarda Rocha",  email: "eduarda.rocha@empresa.com",  document_number: "55555555555", job_title: "Coordenadora de Operações", department: "Operações",      hired_on: "2019-11-20", salary: 11_300, birth_date: "1986-04-17", phone: "11999990005", status: :active },
  { full_name: "Felipe Castro",  email: "felipe.castro@empresa.com",  document_number: "66666666666", job_title: "Desenvolvedor Frontend",  department: "Tecnologia",       hired_on: "2022-09-12", salary: 8_900,  birth_date: "1994-12-01", phone: "11999990006", status: :active },
  { full_name: "Gabriela Pinto", email: "gabriela.pinto@empresa.com", document_number: "77777777777", job_title: "Business Partner de RH",  department: "Recursos Humanos", hired_on: "2018-07-03", salary: 12_500, birth_date: "1985-03-09", phone: "11999990007", status: :on_leave },
  { full_name: "Henrique Dias",  email: "henrique.dias@empresa.com",  document_number: "88888888888", job_title: "Analista de Suporte",     department: "Tecnologia",       hired_on: "2024-01-08", salary: 5_400,  birth_date: "1998-02-25", phone: "11999990008", status: :active },
  { full_name: "Isabela Freitas", email: "isabela.freitas@empresa.com", document_number: "99999999999", job_title: "Controller",            department: "Financeiro",       hired_on: "2017-06-19", salary: 15_800, birth_date: "1983-08-14", phone: "11999990009", status: :active },
  { full_name: "João Martins",   email: "joao.martins@empresa.com",   document_number: "10101010101", job_title: "Gerente Comercial",       department: "Comercial",        hired_on: "2016-04-25", salary: 17_200, birth_date: "1980-10-02", phone: "11999990010", status: :active },
  { full_name: "Karina Melo",    email: "karina.melo@empresa.com",    document_number: "12121212121", job_title: "Analista de Logística",   department: "Operações",        hired_on: "2021-03-30", salary: 6_300,  birth_date: "1996-07-11", phone: "11999990011", status: :active },
  { full_name: "Lucas Barbosa",  email: "lucas.barbosa@empresa.com",  document_number: "13131313131", job_title: "Tech Lead",              department: "Tecnologia",       hired_on: "2015-09-14", salary: 19_000, birth_date: "1987-05-28", phone: "11999990012", status: :terminated, terminated_on: "2025-12-31" }
].freeze

EMPLOYEES.each do |attrs|
  department = Department.find_by!(name: attrs[:department])

  Employee.find_or_create_by!(document_number: attrs[:document_number]) do |employee|
    employee.assign_attributes(attrs.except(:department, :status))
    employee.department = department
    employee.employment_status = attrs[:status]
  end
end

# Vincula usuários do sistema aos seus perfis de funcionário (Etapa 4).
Employee.find_by(email: "ana.souza@empresa.com")&.update!(user: admin) if admin.employee.nil?
Employee.find_by(email: "gabriela.pinto@empresa.com")&.update!(user: manager) if manager.employee.nil?
Employee.find_by(email: "henrique.dias@empresa.com")&.update!(user: colaborador) if colaborador.employee.nil?

puts "== Histórico de alterações (paper_trail) =="
PaperTrail.request(whodunnit: admin.id.to_s) do
  ana = Employee.find_by(email: "ana.souza@empresa.com")
  if ana && ana.job_title != "Tech Lead"
    ana.update!(job_title: "Tech Lead", salary: 12_000)
  end
end

puts "== Notificações =="
[
  { user: admin,   title: "Bem-vindo ao sistema",        body: "Seu acesso de administrador está ativo.",           category: :success },
  { user: admin,   title: "12 funcionários cadastrados", body: "A base inicial de funcionários foi carregada.",      category: :info },
  { user: manager, title: "Funcionária em afastamento",  body: "Gabriela Pinto entrou em licença.",                  category: :warning },
  { user: manager, title: "Alteração de cargo",          body: "Ana Souza foi promovida a Tech Lead.",               category: :info }
].each do |attrs|
  Notification.find_or_create_by!(user: attrs[:user], title: attrs[:title]) do |n|
    n.body = attrs[:body]
    n.category = attrs[:category]
  end
end

puts "\nSeed concluído:"
puts "  Permissions: #{Permission.count}  Roles: #{Role.count}  Departments: #{Department.count}"
puts "  Users: #{User.count}  Employees: #{Employee.count}  Notifications: #{Notification.count}"
puts "  Versions (histórico): #{PaperTrail::Version.count}"
puts "\n  Login de teste: admin@empresa.com / password123"
