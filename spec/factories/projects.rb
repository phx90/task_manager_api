FactoryBot.define do
  factory :project do
    name { "New Project" }
    description { "Project description" }
    association :user
  end
end
