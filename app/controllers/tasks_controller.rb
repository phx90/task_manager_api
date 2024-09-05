class TasksController < ApplicationController
  before_action :authorize_request
  before_action :set_task, only: [:show, :update, :destroy]

  def index
    query = params[:q].presence || "*"
    page = params[:page] || 1
    per_page = params[:per_page] || 10
  
    # Construa o filtro condicionalmente, com valores padrão
    search_filters = {}
    search_filters[:project_id] = params[:project_id] if params[:project_id].present?
    search_filters[:completed] = params[:completed] if params[:completed].present?
  
    # Realiza a pesquisa com Searchkick, considerando os filtros e parâmetros de busca
    tasks = Task.search(
      query,
      where: search_filters,
      fields: [:title, :description],
      match: :word_middle,
      order: { created_at: :desc },
      page: page,
      per_page: per_page
    )
  
    # Se não houver tasks retornadas, mostre uma resposta vazia com os metadados de paginação
    if tasks.blank?
      return render json: { tasks: [], current_page: 1, total_pages: 0, total_count: 0 }, status: :ok
    end
  
    # Retorna as tasks com os metadados
    render json: {
      tasks: tasks.results,
      current_page: tasks.current_page,
      total_pages: tasks.total_pages,
      total_count: tasks.total_count
    }, status: :ok
  end

  # GET /tasks/:id
  def show
    render json: @task, status: :ok
  end

  # POST /tasks
  def create
    project = @current_user.projects.find_by(id: params[:project_id])
    return render json: { errors: ['Projeto não encontrado'] }, status: :not_found unless project

    task = project.tasks.new(task_params)
    return render json: { errors: task.errors.full_messages }, status: :unprocessable_entity unless task.save

    Task.reindex
    render json: task, status: :created
  end

  # PUT /tasks/:id
  def update
    return render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity unless @task.update(task_params)

    Task.reindex
    render json: @task, status: :ok
  end

  # DELETE /tasks/:id
  def destroy
    return render json: { error: 'Erro ao deletar a tarefa' }, status: :unprocessable_entity unless @task.destroy

    Task.reindex
    render json: { message: "Tarefa Deletada" }, status: :ok
  end

  private

  def set_task
    @task = Task.joins(project: :user)
                .where(projects: { user_id: @current_user.id })
                .find_by(id: params[:id])
    return render json: { error: 'Tarefa não encontrada' }, status: :not_found unless @task
  end

  def task_params
    params.require(:task).permit(:title, :description, :completed, :project_id)
  end
end
