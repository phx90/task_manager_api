require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{token_generator(user.id)}" } }

  describe 'GET /users' do
    before(:each) do
      Project.delete_all  
      User.delete_all     
      User.reindex        
    end

    let!(:users) { create_list(:user, 5) }

    it 'returns a list of users with pagination metadata' do
      User.reindex  
      get '/users', headers: headers, params: { page: 1, per_page: 5 }

      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)

      expect(parsed_response['users'].size).to eq(5)  
      expect(parsed_response['total_count']).to eq(5)  
    end
  end

  describe 'DELETE /users/:id' do
    let!(:another_user) { create(:user) }
    let!(:project) { create(:project, user: another_user) }  

    it 'deletes another user and their associated projects' do
      puts "Number of users before deletion: #{User.count}"

      delete "/users/#{another_user.id}", headers: headers
      puts "DELETE /users/:id Response: #{response.body}"  

      User.reindex

      expect(User.count).to eq(1)  
      expect(Project.count).to eq(0)  
      puts "Number of users after deletion: #{User.count}"

      expect(response).to have_http_status(:ok)
      expect(User.exists?(another_user.id)).to be_falsey
      expect(Project.exists?(project.id)).to be_falsey
    end

    it 'deletes the user themselves without needing authorization after deletion' do
      puts "Number of users before deletion: #{User.count}"

      delete "/users/#{user.id}", headers: headers
      puts "DELETE /users/:id Response: #{response.body}"  
  
      expect(User.exists?(user.id)).to be_falsey
      puts "Number of users after deletion: #{User.count}"

      expect(response).to have_http_status(:ok)
    end
  end
end
