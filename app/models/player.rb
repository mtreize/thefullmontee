class Player < ApplicationRecord
  has_and_belongs_to_many :games
  has_many :results
  has_many :performances
  has_many :coffee_bills
    
  def name
    self.results.try(:last).try(:ranking)==1 ? "#{self[:name]}*" : "#{self[:name]}"
  end
  def scores_in_game(g)
    rounds=g.rounds
    Score.where(:player=>self, :round=>rounds)
  end
  
  def nb_payed_coffees_all_time
    self.coffee_bills.pluck(:nb_coffee).sum
  end
  
  def count_trophy(t)
    Performance.where(:player=>self, :trophy=>t).count
  end
  
  
  
end
