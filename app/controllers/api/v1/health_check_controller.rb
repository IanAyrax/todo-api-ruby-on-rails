class Api::V1::HealthCheckController < ApplicationController
  def index
    render json: { message: "Service is running" }, status: :ok
  end
end
