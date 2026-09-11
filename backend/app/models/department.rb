class Department < ApplicationRecord
  has_many :employees, dependent: :restrict_with_error

  normalizes :name, with: ->(value) { value.to_s.strip }

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def to_s
    name
  end
end
