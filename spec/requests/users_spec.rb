# spec/requests/users_spec.rb
require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{token_generator(user.id)}" } }

  describe 'GET /users' do
    before(:each) do
      Project.delete_all  # Limpa todos os projetos
      User.delete_all     # Limpa todos os usuários
      User.reindex        # Reindexa os usuários no searchkick após a limpeza
    end

    let!(:users) { create_list(:user, 5) }

    it 'retorna uma lista de usuários com metadados de paginação' do
      User.reindex  # Reindexa para garantir que os usuários estão no índice
      get '/users', headers: headers, params: { page: 1, per_page: 5 }

      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)

      expect(parsed_response['users'].size).to eq(5)  # Verifica que retornou 5 usuários
      expect(parsed_response['total_count']).to eq(5)  # Verifica que o total é 5
    end
  end

  describe 'DELETE /users/:id' do
    let!(:another_user) { create(:user) }
    let!(:project) { create(:project, user: another_user) }  # Associa um projeto ao usuário

    it 'deleta outro usuário e seus projetos associados' do
      puts "Número de usuários antes da deleção: #{User.count}"

      delete "/users/#{another_user.id}", headers: headers
      puts "DELETE /users/:id Response: #{response.body}"  # Inspeciona a resposta da API

      # Reindexa após a deleção
      User.reindex

      expect(User.count).to eq(1)  # Verifica se um usuário foi excluído
      expect(Project.count).to eq(0)  # Verifica se o projeto associado foi excluído
      puts "Número de usuários após a deleção: #{User.count}"

      expect(response).to have_http_status(:ok)
      expect(User.exists?(another_user.id)).to be_falsey
      expect(Project.exists?(project.id)).to be_falsey
    end

    it 'deleta o próprio usuário sem precisar de autorização após deleção' do
      puts "Número de usuários antes da deleção: #{User.count}"

      delete "/users/#{user.id}", headers: headers
      puts "DELETE /users/:id Response: #{response.body}"  # Inspeciona a resposta da API

      # Verifica se o próprio usuário foi excluído diretamente no banco de dados
      expect(User.exists?(user.id)).to be_falsey
      puts "Número de usuários após a deleção: #{User.count}"

      expect(response).to have_http_status(:ok)
    end
  end
end
