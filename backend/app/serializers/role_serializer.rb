class RoleSerializer
  include Alba::Resource

  attributes :id, :name, :description

  attribute :permissions do |role|
    role.permissions.map(&:name).sort
  end
end
