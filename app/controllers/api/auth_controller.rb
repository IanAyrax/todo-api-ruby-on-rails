class Api::AuthController < ApplicationController
    before_action :authorize_request, except: [:login, :signup]

    # POST /signup
    def signup
        user = User.new(user_params)
        if user.save
            token = encode_token({ user_id: user.id })
            render json: { user: user, token: token }, status: :created
        else
            render json: { error: user.errors.full_messages }, status: :unprocessable_entity
        end
    end

    # POST /login
    def login
        user = User.find_by(email: params[:email])
        
        if user&.authenticate(params[:password])
            token = encode_token({ user_id: user.id })
            render json: { user: user, token: token }, status: :ok
        else
            render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
    end

    private

    def user_params
        params.permit(:email, :password, :password_confirmation)
    end
end
