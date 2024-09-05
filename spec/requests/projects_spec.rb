require 'rails_helper'

RSpec.describe 'Projects API', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let!(:projects) { FactoryBot.create_list(:project, 15, user: user) }

  before do
    Project.reindex # Reindexa o índice de Searchkick no ambiente de teste
    sleep(1) # Garante que o Searchkick tenha tempo para processar a indexação
  end

  let(:headers) { { 'Authorization' => "Bearer #{token_generator(user.id)}" } }

  describe 'GET /projects' do
    it 'returns paginated projects with metadata' do
      get '/projects', headers: headers, params: { page: 1, per_page: 5 }

      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)

      # Verifica se a resposta contém os projetos e a paginação
      expect(parsed_response['projects'].size).to eq(5)
      expect(parsed_response['current_page']).to eq(1)
      expect(parsed_response['total_pages']).to eq(3) # 15 projetos, 5 por página = 3 páginas
      expect(parsed_response['total_count']).to eq(15)
    end
  end

  describe 'POST /projects' do
    let(:valid_attributes) { { name: 'New Project', description: 'Project Description' } }

    it 'creates a new project' do
      expect {
        post '/projects', params: { project: valid_attributes }, headers: headers
      }.to change(Project, :count).by(1)

      expect(response).to have_http_status(:created)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['name']).to eq('New Project')
    end
  end

  describe 'PUT /projects/:id' do
    let(:project) { projects.first }
    let(:valid_attributes) { { name: 'Updated Project', description: 'Updated Description' } }

    it 'updates an existing project' do
      put "/projects/#{project.id}", params: { project: valid_attributes }, headers: headers

      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['name']).to eq('Updated Project')
    end
  end

  describe 'DELETE /projects/:id' do
    let(:project) { projects.first }

    it 'deletes the project' do
      expect {
        delete "/projects/#{project.id}", headers: headers
      }.to change(Project, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end
  end
end
