class Api::V1::NotesController < ApplicationController
  before_action :authorize_request
  before_action :set_note, only: [:show, :update, :destroy]

  # GET /api/v1/notes
  def index
    notes = @current_user.notes
    render json: notes, status: :ok
  end

  # POST /api/v1/notes
  def create
    note = @current_user.notes.new(note_params)
    if note.save
      render json: note, status: :created
    else
      render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/notes/:id
  def show
    render json: @note, status: :ok
  end

  # PUT /api/v1/notes/:id
  def update
    if @note.update(note_params)
      render json: @note, status: :ok
    else
      render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/notes/:id
  def destroy
    @note.destroy
    head :no_content
  end

  private

  def note_params
    params.require(:note).permit(:title, :description, :isCompleted)
  end

  def set_note
    @note = @current_user.notes.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Note not found' }, status: :not_found
  end
end