class Result < ApplicationRecord
  belongs_to :game
  belongs_to :player

  def self.for_game_and_player(game, player)
    return Result.where(:game=>game, :player=>player).try(:first)
  end
end
