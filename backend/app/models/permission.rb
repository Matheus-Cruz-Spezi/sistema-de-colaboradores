class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  normalizes :name, with: ->(value) { value.to_s.strip.downcase }

  # Formato "recurso.acao", ex.: employees.read
  validates :name, presence: true,
                   uniqueness: true,
                   format: { with: /\A[a-z_]+\.[a-z_]+\z/, message: "deve usar o formato recurso.acao" }
end
