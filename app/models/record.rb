class Record < ApplicationRecord
  belongs_to :player, :optional=>true
  belongs_to :game, :optional=>true

  def self.compute_records_for_game(g)
    self.highest_score_record(g)
    self.lowest_score_record(g)
  end
  
  def self.highest_score_record(g)
    gmax=Result.where(:game=>g).pluck(:total_score).max || 0
    r=Record.where(:name=>"Meilleur score à #{g.players.count}").first_or_initialize
    r.value=0 if r.value.nil?
    if gmax > r.value
      r.player=Result.where(:game=>g, :total_score=>gmax).first.player
      r.value=gmax
      r.game=g
      r.save
    end
  end
  
  def self.lowest_score_record(g)
    gmin=Result.where(:game=>g).pluck(:total_score).min || 1000
    r=Record.where(:name=>"Plus mauvais score à #{g.players.count}").first_or_initialize
    r.value=1000 if r.value.nil?
    if gmin < r.value
      r.player=Result.where(:game=>g, :total_score=>gmin).first.player
      r.value=gmin
      r.game=g
      r.save
    end
  end
end
