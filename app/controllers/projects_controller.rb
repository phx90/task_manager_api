class ProjectsController < ApplicationController
  before_action :authorize_request
  before_action :set_project, only: [:show, :update, :destroy]

  def index
    query = params[:q].presence || "*"
    page = params[:page] || 1
    per_page = params[:per_page] || 5

    projects = Project.search(
      query,
      where: { user_id: @current_user.id },  # Filtra projetos do usuário autenticado
      fields: [:name, :description],         # Campos de busca
      match: :word_middle,                   # Busca por palavras parciais
      order: { created_at: :desc },          # Ordena por data de criação
      page: page,
      per_page: per_page                     # Paginação
    )

    render json: {
      projects: projects.results,
      current_page: projects.current_page,
      total_pages: projects.total_pages,
      total_count: projects.total_count
    }, status: :ok
  end

  def show
    render json: @project, include: :tasks, status: :ok
  end

  def create
    project = @current_user.projects.new(project_params)
    if project.save
      render json: project, status: :created
    else
      render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      render json: @project, status: :ok
    else
      render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def destroy
    @project.destroy
    render json: { message: "Projeto Deletado" }, status: :ok
  end

  private

  def set_project
    @project = @current_user.projects.find_by(id: params[:id])
    render json: { error: 'Projeto não encontrado' }, status: :not_found unless @project
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
