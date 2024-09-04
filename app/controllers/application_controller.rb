class ApplicationController < ActionController::API
  before_action :authorize_request

  def authorize_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = JsonWebToken.decode(token)
    @current_user = User.find_by(id: decoded[:user_id]) if decoded
    return render json: { errors: 'Unauthorized' }, status: :unauthorized unless @current_user
  rescue JWT::DecodeError
    render json: { errors: 'Unauthorized' }, status: :unauthorized
  end
end
