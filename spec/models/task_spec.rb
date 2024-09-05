require 'rails_helper'

RSpec.describe Task, type: :model do

  it { should belong_to(:project) }


  it { should validate_presence_of(:title) }


  it 'is valid with valid attributes' do
    user = FactoryBot.create(:user)
    project = FactoryBot.create(:project, user: user)
    task = FactoryBot.build(:task, project: project)
    expect(task).to be_valid
  end


  it 'is invalid without a title' do
    task = FactoryBot.build(:task, title: nil)
    expect(task).not_to be_valid
  end
end
