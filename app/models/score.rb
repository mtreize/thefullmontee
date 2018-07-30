class Score < ApplicationRecord
  belongs_to :player
  belongs_to :round
  validates_uniqueness_of :player, :scope => :round

  def self.recompute_all_tmp_totals
    Score.order(:round_id).each do |s|
      tot=Score.where(:player_id=>s.player_id, :round_id=>s.round.game.rounds.where("number <= ?",s.round.number).pluck(:id)).sum(:value)
      s.tmp_total=tot
      s.save
    end
  end
  def self.recompute_all_rankings
    Score.order(:round_id).each do |s|
      scores=s.round.scores.pluck(:player_id, :tmp_total).to_h
      sorted=Hash[scores.sort_by{|k, v| v}.reverse]
      rankings={}
      previous=[]
      sorted.each_with_index do |res, i|
        if previous.present? && res.second==previous.second
          rankings[res.first]=rankings[previous.first]
        else
          rankings[res.first]=i+1
        end
        previous=res
      end
      rank=rankings[s.player_id]
      s.tmp_ranking=rank
      s.save
    end
  end
end
