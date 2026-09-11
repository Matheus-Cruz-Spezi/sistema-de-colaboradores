require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  setup do
    @department = departments(:tecnologia)
  end

  def build_employee(**overrides)
    Employee.new({
      full_name: "Novo Funcionário",
      email: "novo@empresa.com",
      document_number: "45678912300",
      job_title: "Analista",
      department: @department,
      hired_on: Date.new(2024, 1, 10)
    }.merge(overrides))
  end

  test "válido com os atributos mínimos" do
    assert build_employee.valid?
  end

  test "exige nome, cargo, admissão e departamento" do
    employee = Employee.new
    assert_not employee.valid?
    assert_includes employee.errors.attribute_names, :full_name
    assert_includes employee.errors.attribute_names, :job_title
    assert_includes employee.errors.attribute_names, :hired_on
    assert_includes employee.errors.attribute_names, :department
  end

  test "normaliza e valida o CPF com 11 dígitos" do
    employee = build_employee(document_number: "456.789.123-00")
    assert employee.valid?
    assert_equal "45678912300", employee.document_number

    assert_not build_employee(document_number: "123").valid?
  end

  test "e-mail é único" do
    duplicate = build_employee(email: employees(:ana).email.upcase)
    assert_not duplicate.valid?
    assert_includes duplicate.errors.attribute_names, :email
  end

  test "desligamento não pode ser antes da admissão" do
    employee = build_employee(hired_on: Date.new(2024, 1, 1), terminated_on: Date.new(2023, 12, 31))
    assert_not employee.valid?
    assert_includes employee.errors.attribute_names, :terminated_on
  end

  test "salário não pode ser negativo" do
    assert_not build_employee(salary: -1).valid?
  end

  test "enum de situação" do
    assert employees(:ana).active?
    assert employees(:bruno).on_leave?
  end

  test "scope search encontra por nome, e-mail ou cargo" do
    assert_includes Employee.search("ana"), employees(:ana)
    assert_includes Employee.search("bruno.lima@empresa"), employees(:bruno)
    assert_equal Employee.count, Employee.search("").count
  end

  test "registra histórico no paper_trail ao alterar" do
    employee = build_employee
    assert_difference -> { PaperTrail::Version.where(item_type: "Employee").count }, 2 do
      employee.save!
      employee.update!(job_title: "Analista Sênior")
    end
    assert_equal "Analista", employee.versions.last.reify.job_title
  end
end
