class VersionSerializer
  include Alba::Resource

  attributes :id, :item_type, :item_id, :event, :created_at

  attribute :changed_by do |version|
    next nil if version.whodunnit.blank?

    User.find_by(id: version.whodunnit)&.email || version.whodunnit
  end

  # Diff da alteração: { campo => [antes, depois] }
  attribute :changes do |version|
    version.object_changes
  end
end
