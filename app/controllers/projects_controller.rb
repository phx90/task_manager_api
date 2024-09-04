class ProjectsController < ApplicationController
  before_action :authorize_request
  before_action :set_project, only: [:show, :update, :destroy]

  # GET /projects
  def index
    projects = @current_user.projects
    render json: projects, status: :ok
  end

  # GET /projects/:id
  def show
    render json: @project, status: :ok
  end

  # POST /projects
  def create
    project = @current_user.projects.new(project_params)
    return render json: { errors: project.errors.full_messages }, status: :unprocessable_entity unless project.save
    
    render json: project, status: :created
  end

  # PUT /projects/:id
  def update
    return render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity unless @project.update(project_params)

    render json: @project, status: :ok
  end

  # DELETE /projects/:id
  def destroy
    @project.destroy
    head :no_content
  end

  private

  def set_project
    @project = @current_user.projects.find_by(id: params[:id])
    return render json: { error: 'Project not found' }, status: :not_found unless @project
  end

  def project_params
    params.permit(:name, :description)
  end
end
