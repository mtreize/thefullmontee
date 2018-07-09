class Player < ApplicationRecord
  has_and_belongs_to_many :games
  has_many :results
  has_many :performances
    
  def scores_in_game(g)
    rounds=g.rounds
    Score.where(:player=>self, :round=>rounds)
  end
  
    
end
