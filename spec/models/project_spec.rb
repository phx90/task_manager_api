require 'rails_helper'

RSpec.describe Project, type: :model do
  # Testa associações
  it { should belong_to(:user) }
  it { should have_many(:tasks).dependent(:destroy) }

  # Testa validações
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:description) }

  # Testa criação válida de projeto
  it 'is valid with valid attributes' do
    user = FactoryBot.create(:user)
    project = FactoryBot.build(:project, user: user)
    expect(project).to be_valid
  end

  # Testa criação inválida de projeto
  it 'is invalid without a name' do
    project = FactoryBot.build(:project, name: nil)
    expect(project).not_to be_valid
  end
end
