class Role < ApplicationRecord
  ADMIN    = "admin".freeze
  MANAGER  = "manager".freeze
  EMPLOYEE = "employee".freeze
  DEFAULT  = EMPLOYEE

  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions
  has_many :users, dependent: :restrict_with_error

  normalizes :name, with: ->(value) { value.to_s.strip.downcase }

  validates :name, presence: true, uniqueness: true

  def self.default
    find_by(name: DEFAULT)
  end

  def permission?(permission_name)
    permissions.exists?(name: permission_name.to_s)
  end
end
