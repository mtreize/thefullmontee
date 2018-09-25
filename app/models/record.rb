class Record < ApplicationRecord
  belongs_to :player, :optional=>true
  belongs_to :game, :optional=>true

  def self.compute_records_for_game(g)
    self.highest_score_record(g)
    self.lowest_score_record(g)
    self.longest_victory_serie(g)
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
  
  def self.longest_victory_serie(g)
    r=Record.where(:name=>"Série de victoires").first
    return false if r.blank?
    serie=Result.where(:game=>g, :ranking=>[1]).map(&:player).map(&:stars).map(&:length).max
    if serie > r.value
      h=Hash.new
      Result.where(:game=>g, :ranking=>[1]).map(&:player).each do |p|
        h[p.id]=p.stars.length
      end
      play=h.max_by{|k,v| v}.first
      r.player=Player.find(play)
      r.value=h.max_by{|k,v| v}.second
      r.game=g
      r.save
    end
  end

end
