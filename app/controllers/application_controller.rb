class ApplicationController < ActionController::API
    SECRET_KEY = Rails.application.secrets.secret_key_base.to_s
    
    def encode_token(payload, exp = 24.hours.from_now)
        payload[:exp] = exp.to_i
        JWT.encode(payload, SECRET_KEY)
    end

    def decode_token
        auth_header = request.headers['Authorization']
        if auth_header
            token = auth_header.split(' ').last
            begin
                JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')
            rescue JWT::DecodeError
                nil
            end
        end
    end

    def authorize_request
        decoded = decode_token
        
        if decoded
            user_id = decoded[0]['user_id']
            @current_user = User.find_by(id: user_id)
        end
        render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
    end
end
