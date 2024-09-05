require 'rails_helper'

RSpec.describe 'Tasks API', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:project) { FactoryBot.create(:project, user: user) }
  let!(:tasks) { FactoryBot.create_list(:task, 12, project: project) }

  before do
    Task.reindex
    sleep(1)  # Garante que o Searchkick complete a reindexação
  end

  let(:headers) { { 'Authorization' => "Bearer #{token_generator(user.id)}" } }

  describe 'GET /tasks' do
    it 'returns paginated tasks with metadata' do
      get '/tasks', headers: headers, params: { page: 1, per_page: 5, project_id: project.id }

      puts "GET /tasks Response: #{response.body}"  # Log da resposta

      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)

      # Verifica se a resposta contém as tarefas e a paginação
      expect(parsed_response['tasks'].size).to eq(5)
      expect(parsed_response['current_page']).to eq(1)
      expect(parsed_response['total_pages']).to eq(3)  # 12 tarefas, 5 por página = 3 páginas
      expect(parsed_response['total_count']).to eq(12)
    end
  end

  describe 'POST /tasks' do
    let(:valid_attributes) { { title: 'New Task', description: 'Task Description', completed: false } }

    it 'creates a new task' do
      expect {
        post '/tasks', params: { task: valid_attributes, project_id: project.id }, headers: headers
        puts "POST /tasks Response: #{response.body}"  # Log da resposta para depuração
      }.to change(Task, :count).by(1)

      expect(response).to have_http_status(:created)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['title']).to eq('New Task')

      # Reindexar novamente para garantir que a nova tarefa seja indexada corretamente
      Task.reindex
      sleep(1)
    end
  end

  describe 'DELETE /tasks/:id' do
    let(:task) { tasks.first }

    it 'deletes the task' do
      expect {
        delete "/tasks/#{task.id}", headers: headers
        puts "DELETE /tasks/:id Response: #{response.body}"  # Log da resposta para depuração
      }.to change(Task, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end
  end
end
