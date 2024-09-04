class AuthenticationController < ApplicationController
  skip_before_action :authorize_request, only: [:signup, :login]
  def signup
    user = User.new(user_params)
    return render json: { errors: user.errors.full_messages }, status: :unprocessable_entity unless user.save

    token = JsonWebToken.encode(user_id: user.id)
    render json: { token: token }, status: :created
  end

  def login
    user = User.find_by(email: params[:email])
    return render json: { error: 'Invalid credentials' }, status: :unauthorized unless user&.authenticate(params[:password])

    token = JsonWebToken.encode(user_id: user.id)
    render json: { token: token }, status: :ok
  end

  private

  def user_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end