class User < ApplicationRecord
  has_secure_password

  EMAIL_FORMAT = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

  belongs_to :role
  has_one :employee, dependent: :nullify
  has_many :notifications, dependent: :destroy

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  before_validation :assign_default_role, on: :create

  validates :email, presence: true, uniqueness: true, format: { with: EMAIL_FORMAT }
  validates :password, length: { minimum: 8 }, allow_nil: true

  delegate :name, to: :role, prefix: true, allow_nil: true

  # Perfis (Etapa 4)
  def admin? = role_name == Role::ADMIN
  def manager? = role_name == Role::MANAGER
  def colaborador? = role_name == Role::EMPLOYEE

  # Nível de acesso: o usuário pode executar a ação `permission_name`?
  def can?(permission_name)
    role&.permission?(permission_name) || false
  end

  # Campos expostos na API — nunca inclui o password_digest.
  def as_json(options = {})
    super(options.reverse_merge(only: %i[id email created_at updated_at]))
      .merge("role" => role_name)
  end

  private

  def assign_default_role
    self.role ||= Role.default
  end
end
