require 'rails_helper'

RSpec.describe User, type: :model do

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }

  describe 'Email uniqueness validations (case-insensitive)' do
    let!(:user) { create(:user, email: 'test1@example.com') } 

    it 'does not allow duplicate email regardless of case' do
      duplicate_user = build(:user, email: 'TEST1@example.com')
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include('has already been taken')
    end
  end

  it 'allows valid email formats' do
    user = build(:user, email: 'valid_email@example.com')
    expect(user).to be_valid
  end

  it 'does not allow invalid email formats' do
    user = build(:user, email: 'invalid-email')
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include('is invalid')
  end


  it { should have_many(:projects).dependent(:destroy) }
  it { should have_secure_password }
end
