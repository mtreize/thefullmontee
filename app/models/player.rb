class Player < ApplicationRecord
  has_and_belongs_to_many :games
  has_many :results
  has_many :performances
  has_many :coffee_bills
    
  def name
    return "#{self[:name]}#{self.stars}"
  end    
  
  def stars
    if self.results.try(:last).try(:ranking)==1 
      if self.results.try(:last, 2).try(:first).try(:ranking)==1 && self.games.count>1 
        if self.results.try(:last, 3).try(:first).try(:ranking)==1 && self.games.count>2 
          if self.results.try(:last, 4).try(:first).try(:ranking)==1 && self.games.count>3 
            if self.results.try(:last, 5).try(:first).try(:ranking)==1 && self.games.count>4 
              return "*****"
            else
              return "****"
            end
          else
            return "***"
          end
        else
          return "**"
        end
      else 
        return "*"
      end
    else 
      return ""
    end
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
