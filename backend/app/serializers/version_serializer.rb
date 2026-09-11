class VersionSerializer
  include Alba::Resource

  FIELD_LABELS = {
    "full_name" => "Nome completo",
    "email" => "E-mail",
    "document_number" => "CPF",
    "job_title" => "Cargo",
    "phone" => "Telefone",
    "employment_status" => "Situação",
    "hired_on" => "Admissão",
    "terminated_on" => "Desligamento",
    "birth_date" => "Nascimento",
    "salary" => "Salário",
    "department_id" => "Departamento",
    "user_id" => "Usuário vinculado"
  }.freeze

  STATUS_LABELS = { "active" => "Ativo", "on_leave" => "Afastado", "terminated" => "Desligado" }.freeze

  IGNORED_FIELDS = %w[id created_at updated_at].freeze

  attributes :id, :item_type, :item_id, :event, :created_at

  attribute :changed_by do |version|
    next nil if version.whodunnit.blank?

    User.find_by(id: version.whodunnit)&.email || version.whodunnit
  end

  # De quem é o perfil afetado — cai para o snapshot gravado na versão quando
  # o funcionário já foi removido (o registro ao vivo não existe mais).
  attribute :employee do |version|
    next nil unless version.item_type == "Employee"

    name = version.item&.full_name ||
           version.object&.dig("full_name") ||
           version.object_changes&.dig("full_name")&.last

    { id: version.item_id, full_name: name || "Funcionário removido" }
  end

  # Diff legível da alteração: [{ field, label, before, after }]
  attribute :changes do |version|
    (version.object_changes || {}).except(*IGNORED_FIELDS).map do |field, (before, after)|
      {
        field: field,
        label: FIELD_LABELS[field] || field.humanize,
        before: VersionSerializer.humanize_value(field, before),
        after: VersionSerializer.humanize_value(field, after)
      }
    end
  end

  def self.humanize_value(field, value)
    return "—" if value.nil?

    case field
    when "salary"
      ActiveSupport::NumberHelper.number_to_currency(value, unit: "R$ ", separator: ",", delimiter: ".")
    when "employment_status"
      STATUS_LABELS[value] || value
    when "hired_on", "terminated_on", "birth_date"
      Date.parse(value.to_s).strftime("%d/%m/%Y")
    when "department_id"
      Department.find_by(id: value)&.name || "Departamento ##{value}"
    when "user_id"
      User.find_by(id: value)&.email || "—"
    else
      value.to_s
    end
  rescue ArgumentError, TypeError
    value.to_s
  end
end
