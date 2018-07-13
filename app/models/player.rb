class Player < ApplicationRecord
  has_and_belongs_to_many :games
  has_many :results
  has_many :performances
  has_many :coffee_bills
    
  def scores_in_game(g)
    rounds=g.rounds
    Score.where(:player=>self, :round=>rounds)
  end
  
  def nb_payed_coffees_all_time
    self.coffee_bills.pluck(:nb_coffee).sum
  end
  
    
end
