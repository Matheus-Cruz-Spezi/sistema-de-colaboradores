class EmployeeSerializer
  include Alba::Resource

  attributes :id, :full_name, :email, :document_number, :job_title, :phone,
             :employment_status, :hired_on, :terminated_on, :birth_date,
             :department_id, :user_id, :created_at, :updated_at

  attribute :salary do |employee|
    employee.salary&.to_f
  end

  # Papel do usuário vinculado (ou nil) — usado pelo frontend para decidir
  # se o perfil pode ser editado.
  attribute :user_role do |employee|
    employee.user&.role_name
  end

  association :department, resource: DepartmentSerializer
end
