class RoundsController < ApplicationController
  before_action :fetch_round, only: :update

  def update
    service_args = update_params.to_h.merge!(round: @round)
    service = ScoreUpdater.new(service_args)

    if service.call
      render json: @round.game, status: :ok
    else
      render json: { error: service.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def update_params
    params.require(:round).permit(:pins, :roll)
  end

  def fetch_round
    @round = Round.find_by(id: params[:id])
  end
end
