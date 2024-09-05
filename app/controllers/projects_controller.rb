class ProjectsController < ApplicationController
  before_action :authorize_request
  before_action :set_project, only: [:show, :update, :destroy]

  def index
    query = params[:q].presence || "*"
    page = params[:page] || 1
    per_page = params[:per_page] || 5

    projects = Project.search(
      query,
      where: { user_id: @current_user.id },  
      fields: [:name, :description],         
      match: :word_middle,                   
      order: { created_at: :desc },          
      page: page,
      per_page: per_page                     
    )

    render json: {
      projects: projects.results,
      current_page: projects.current_page,
      total_pages: projects.total_pages,
      total_count: projects.total_count
    }, status: :ok
  end

  def show
    return render json: { error: 'Project not found' }, status: :not_found unless @project
    render json: @project, include: :tasks, status: :ok
  end

  def create
    project = @current_user.projects.new(project_params)
    return render json: { errors: project.errors.full_messages }, status: :unprocessable_entity unless project.save

    render json: project, status: :created
  end

  def update
    return render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity unless @project.update(project_params)

    render json: @project, status: :ok
  end

  def destroy
    @project.destroy
    render json: { message: 'Project deleted' }, status: :ok
  end

  private

  def set_project
    @project = @current_user.projects.find_by(id: params[:id])
    return render json: { error: 'Project not found' }, status: :not_found unless @project
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
