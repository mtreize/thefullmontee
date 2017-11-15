class Player < ApplicationRecord
  has_and_belongs_to_many :games

  def scores_in_game(g)
    rounds=g.rounds
    Score.where(:player=>self, :round=>rounds)
  end
        
    
end
