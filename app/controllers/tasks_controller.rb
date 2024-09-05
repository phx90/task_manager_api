class TasksController < ApplicationController
  before_action :authorize_request
  before_action :set_task, only: [:show, :update, :destroy]

  def index
    query = params[:q].presence || "*"
    page = params[:page] || 1
    per_page = params[:per_page] || 10
  
    search_filters = {}
    search_filters[:project_id] = params[:project_id] if params[:project_id].present?
    search_filters[:completed] = params[:completed] if params[:completed].present?
  
    tasks = Task.search(
      query,
      where: search_filters,
      fields: [:title, :description],
      match: :word_middle,
      order: { created_at: :desc },
      page: page,
      per_page: per_page
    )
  
    if tasks.blank?
      return render json: { tasks: [], current_page: 1, total_pages: 0, total_count: 0 }, status: :ok
    end
  
    render json: {
      tasks: tasks.results,
      current_page: tasks.current_page,
      total_pages: tasks.total_pages,
      total_count: tasks.total_count
    }, status: :ok
  end

  def show
    render json: @task, status: :ok
  end

  def create
    project = @current_user.projects.find_by(id: params[:project_id])
    return render json: { errors: ['Project not found'] }, status: :not_found unless project

    task = project.tasks.new(task_params)
    return render json: { errors: task.errors.full_messages }, status: :unprocessable_entity unless task.save

    Task.reindex
    render json: task, status: :created
  end

  def update
    return render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity unless @task.update(task_params)

    Task.reindex
    render json: @task, status: :ok
  end

  def destroy
    return render json: { error: 'Error deleting the task' }, status: :unprocessable_entity unless @task.destroy

    Task.reindex
    render json: { message: "Task deleted" }, status: :ok
  end

  private

  def set_task
    @task = Task.joins(project: :user)
                .where(projects: { user_id: @current_user.id })
                .find_by(id: params[:id])
    return render json: { error: 'Task not found' }, status: :not_found unless @task
  end

  def task_params
    params.require(:task).permit(:title, :description, :completed, :project_id)
  end
end
