class GamesController < ApplicationController
  def create
    game = Game.new(game_params)
    game.status = 'started'
    if game.save
      render json: game, status: :created
    else
      render json: { error: game.errors.messages }, status: :unprocessable_entity
    end
  end

  def show
    game = Game.find_by_id(params[:id])
    if game.present?
      render json: game, status: :ok
    else
      render json: { error: I18n.t('game.errors.not_found') }, status: :not_found
    end
  end

  private

  def game_params
    params.require(:game).permit(players_attributes: [:name])
  end
end
