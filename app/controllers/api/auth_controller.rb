class Api::AuthController < ApplicationController
    before_action :authorize_request, except: [:login, :signup]

    # POST /signup
    def signup
        user = User.new(user_params)
        if user.save
            # token = encode_token({ user_id: user.id })
            # render json: { user: user, token: token }, status: :created

            tokens = generate_tokens(user)
            render json: tokens, status: :created
        else
            render json: { error: user.errors.full_messages }, status: :unprocessable_entity
        end
    end

    # POST /login
    def login
        user = User.find_by(email: params[:email])
        
        if user&.authenticate(params[:password])
            #token = encode_token({ user_id: user.id })
            #render json: { user: user, token: token }, status: :ok

            tokens = generate_tokens(user)
            render json: tokens, status: :created
        else
            render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
    end

    # POST /api/refresh
    def refresh
        refresh_token = request.headers['Authorization']&.split(' ')&.last
        payload = JsonWebToken.decode(refresh_token)

        if payload
            user = User.find_by(id: payload[:user_id])
            if user
                access_token = JsonWebToken.encode({ user_id: user.id }, 15.minutes.from_now)
                render json: { access_token: access_token }, status: :ok
            else
                render json: { error: 'User not found' }, status: :not_found
            end
        else
            render json: { error: 'Invalid or expired refresh token' }, status: :unauthorized
        end
    end

    private

    def user_params
        params.permit(:email, :password, :password_confirmation)
    end

    def generate_tokens(user)
        {
        access_token: JsonWebToken.encode({ user_id: user.id }, 1.hours.from_now),
        refresh_token: JsonWebToken.encode({ user_id: user.id }, 30.days.from_now)
        }
    end
end
