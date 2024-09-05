FactoryBot.define do
  factory :task do
    title { "New Task" }
    description { "Task description" }
    completed { false }
    association :project
  end
end
