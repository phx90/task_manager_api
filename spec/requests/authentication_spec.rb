require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  let(:user) { FactoryBot.create(:user) }
  
  # Teste para Signup
  describe 'POST /signup' do
    it 'creates a new user' do
      expect {
        post '/signup', params: { name: 'User', email: 'user@example.com', password: 'password', password_confirmation: 'password' }
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end

  # Teste para Login
  describe 'POST /login' do
    it 'authenticates the user' do
      post '/login', params: { email: user.email, password: user.password }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include('token')
    end
  end
end
