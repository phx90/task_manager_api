class Task < ApplicationRecord
  belongs_to :project

  validates :title, presence: true
  validates :completed, inclusion: { in: [true, false], message: "must be true or false" }
  validates :project_id, presence: true

  searchkick

  def search_data
    {
      title: title,
      description: description,
      completed: completed,
      project_id: project_id,
      created_at: created_at
    }
  end
end
