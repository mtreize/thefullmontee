class Player < ApplicationRecord
  has_and_belongs_to_many :games
  has_many :results
  has_many :performances
  has_many :coffee_bills
    
  def name
    nam="#{self[:name]}"
    nam+=self.results.try(:last).try(:ranking)==1 ? self.results.try(:last, 2).try(:first).try(:ranking)==1 && self.games.count>1 ?  "**" : "*" : ""
    return nam
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
