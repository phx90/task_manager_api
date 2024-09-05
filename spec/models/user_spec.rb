require 'rails_helper'

RSpec.describe User, type: :model do
  # Validações de presença
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }

  describe 'validações de unicidade de e-mail (case-insensitive)' do
    let!(:user) { create(:user, email: 'test1@example.com') }  # Muda para evitar duplicidade

    it 'não permite e-mail duplicado independentemente do caso' do
      duplicate_user = build(:user, email: 'TEST1@example.com')
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include('has already been taken')
    end
  end

  it 'permite formatos válidos de e-mail' do
    user = build(:user, email: 'valid_email@example.com')
    expect(user).to be_valid
  end

  it 'não permite formatos inválidos de e-mail' do
    user = build(:user, email: 'invalid-email')
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include('is invalid')
  end

  # Associações
  it { should have_many(:projects).dependent(:destroy) }
  it { should have_secure_password }
end
