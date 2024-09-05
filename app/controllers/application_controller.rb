class ApplicationController < ActionController::API
  before_action :authorize_request

  def authorize_request
    header = request.headers['Authorization']
    return render json: { errors: 'Unauthorized' }, status: :unauthorized unless header.present?

    token = header.split(' ').last
    decoded = JsonWebToken.decode(token) rescue nil
    return render json: { errors: 'Unauthorized' }, status: :unauthorized unless decoded

    @current_user = User.find_by(id: decoded[:user_id])
    return render json: { errors: 'Unauthorized' }, status: :unauthorized unless @current_user
  end
end
