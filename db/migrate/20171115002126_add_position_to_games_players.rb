class AddPositionToGamesPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :games_players, :position, :integer
  end
end
