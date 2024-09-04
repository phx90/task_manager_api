class TasksController < ApplicationController
  before_action :authorize_request
  before_action :set_task, only: [:show, :update, :destroy]

  # GET /tasks
  def index
    tasks = @current_user.projects.joins(:tasks).select('tasks.*')
    render json: tasks, status: :ok
  end

  # GET /tasks/:id
  def show
    render json: @task, status: :ok
  end

  # POST /tasks
  def create
    project = @current_user.projects.find_by(id: params[:project_id])
    return render json: { error: 'Project not found' }, status: :not_found unless project

    task = project.tasks.new(task_params)
    return render json: { errors: task.errors.full_messages }, status: :unprocessable_entity unless task.save

    render json: task, status: :created
  end

  # PUT /tasks/:id
  def update
    return render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity unless @task.update(task_params)

    render json: @task, status: :ok
  end

  # DELETE /tasks/:id
  def destroy
    @task.destroy
    head :no_content
  end

  private

  def set_task
    @task = @current_user.projects.joins(:tasks).find_by('tasks.id': params[:id])
    return render json: { error: 'Task not found' }, status: :not_found unless @task
  end

  def task_params
    params.permit(:title, :description, :completed)
  end
end
