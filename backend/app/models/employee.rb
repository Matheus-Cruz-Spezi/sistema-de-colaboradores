class Employee < ApplicationRecord
  # Histórico de alterações (paper_trail) — guarda inclusive o diff.
  has_paper_trail

  EMAIL_FORMAT = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

  belongs_to :department
  belongs_to :user, optional: true
  has_many :notifications, as: :notifiable, dependent: :nullify

  enum :employment_status, { active: 0, on_leave: 1, terminated: 2 }, default: :active

  normalizes :email, with: ->(value) { value.to_s.strip.downcase }
  normalizes :document_number, with: ->(value) { value.to_s.gsub(/\D/, "") }

  validates :full_name, presence: true, length: { minimum: 2 }
  validates :email, presence: true, uniqueness: true, format: { with: EMAIL_FORMAT }
  validates :document_number, presence: true, uniqueness: true,
                              format: { with: /\A\d{11}\z/, message: "deve ter 11 dígitos" }
  validates :job_title, presence: true
  validates :hired_on, presence: true
  validates :salary, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :terminated_on_after_hired_on

  scope :search, lambda { |term|
    next all if term.blank?

    pattern = "%#{term.to_s.strip.downcase}%"
    where(
      "LOWER(full_name) LIKE :q OR LOWER(email) LIKE :q OR LOWER(job_title) LIKE :q",
      q: pattern
    )
  }
  scope :by_department, ->(department_id) { department_id.present? ? where(department_id:) : all }
  scope :by_status, lambda { |status|
    employment_statuses.key?(status.to_s) ? where(employment_status: status) : all
  }

  private

  def terminated_on_after_hired_on
    return if terminated_on.blank? || hired_on.blank?
    return if terminated_on >= hired_on

    errors.add(:terminated_on, "deve ser posterior à data de admissão")
  end
end
