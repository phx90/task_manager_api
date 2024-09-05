require 'rails_helper'

RSpec.describe Task, type: :model do
  # Testa associações
  it { should belong_to(:project) }

  # Testa validações
  it { should validate_presence_of(:title) }

  # Testa criação válida de tarefa
  it 'is valid with valid attributes' do
    user = FactoryBot.create(:user)
    project = FactoryBot.create(:project, user: user)
    task = FactoryBot.build(:task, project: project)
    expect(task).to be_valid
  end

  # Testa criação inválida de tarefa
  it 'is invalid without a title' do
    task = FactoryBot.build(:task, title: nil)
    expect(task).not_to be_valid
  end
end
