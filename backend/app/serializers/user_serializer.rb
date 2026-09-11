class UserSerializer
  include Alba::Resource

  attributes :id, :email, :created_at, :updated_at

  attribute :role do |user|
    user.role_name
  end
end
