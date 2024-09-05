class Project < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy
  validates :name, presence: true
  validates :description, presence: true
  searchkick 


  def search_data
    {
      name: name,
      description: description,
      user_id: user_id,
      created_at: created_at
    }
  end
end