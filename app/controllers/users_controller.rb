# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :authorize_request
  before_action :set_user, only: [:show, :update, :destroy]

  def index
    query = params[:q].presence || "*"
    page = params[:page] || 1
    per_page = params[:per_page] || 10

    users = User.search(
      query,
      fields: [:name, :email],
      match: :word_middle,
      order: { created_at: :desc },
      page: page,
      per_page: per_page
    )

    render json: {
      users: users.results,
      current_page: users.current_page,
      total_pages: users.total_pages,
      total_count: users.total_count
    }, status: :ok
  end


  def show
    render json: @user, status: :ok
  end


  def update
    return render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity unless @user.update(user_params)

    render json: @user, status: :ok
  end

  def destroy
    return render json: { error: 'Usuário não encontrado' }, status: :not_found unless @user

    return render json: { error: 'Erro ao deletar o usuário' }, status: :unprocessable_entity unless @user.destroy

    User.reindex  # Reindexa após a deleção
    render json: { message: 'Usuário Deletado' }, status: :ok
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    return render json: { error: 'Usuário não encontrado' }, status: :not_found unless @user
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
