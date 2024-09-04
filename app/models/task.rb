class Task < ApplicationRecord
  belongs_to :project

  validates :title, presence: true
  validates :completed, inclusion: { in: [true, false] }
end