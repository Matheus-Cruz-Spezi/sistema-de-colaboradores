class DepartmentSerializer
  include Alba::Resource

  attributes :id, :name, :description, :created_at, :updated_at

  attribute :employees_count do |department|
    # Usa a coluna calculada no SELECT quando disponível; senão consulta.
    department.attributes["employees_count"] || department.employees.count
  end
end
