class Round < ApplicationRecord
  belongs_to :game
  validates_uniqueness_of :number, :scope => :game
  has_many :scores , dependent: :destroy
    
    def previous_rounds_in_game
      Round.where("game_id = ? AND number < ?", self.game_id, self.number)
    end
    def current_total_for_player(p)
      Score.all.where(:player=>p, :round=>(self.previous_rounds_in_game)).pluck(:value).sum.inspect
    end
    def display
      return "#{self.game.title} / ROUND #{self.number}"
    end
    def previous
      Round.where(:game=>self.game, :number=>(self.number-1)).try(:first)
    end
    def next
      Round.where(:game=>self.game, :number=>(self.number+1)).try(:first)
    end
    def score_for_player(p)
      Score.where(:player=>p, :round=>self).try(:first)
    end
end
