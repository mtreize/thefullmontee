class Trophy < ApplicationRecord
  has_many :performances
  scope :active, -> { where(active: true) }

  enum positive: { pasbien: 4, neutre: 5, bien: 6}
  enum only_once: { une_seule_fois: 1, plusieurs_fois: 0}
  
  
  def self.unlock_victory(game, player)
    t=Trophy.find_by_technical_name('victory')
    if Result.for_game_and_player(game, player).ranking==1
        p=Performance.where(:game=>game,:player=>player, :trophy=>t).first_or_initialize
        p.save
        return true
    else
        Performance.where(:game=>game,:player=>player, :trophy=>t).destroy_all
        return false
    end
  end
  
  def self.unlock_one_point_winner(game, player)
    t=Trophy.find_by_technical_name('one_point_winner')
    
    score_premier= Result.where(:game=>game, :ranking=>1).try(:first).try(:total_score) || 1000
    score_second= Result.where(:game=>game, :ranking=>2).try(:first).try(:total_score) || 1000
    diff=score_premier-score_second
    if Result.for_game_and_player(game, player).ranking==1 && diff==1
        p=Performance.where(:game=>game,:player=>player, :trophy=>t).first_or_initialize
        p.save
        return true
    else
        Performance.where(:game=>game,:player=>player, :trophy=>t).destroy_all
        return false
    end
  end
  
  def self.unlock_modjo(game, player)
    t=Trophy.find_by_technical_name('modjo')
    Performance.where(:game=>game,:player=>player, :trophy=>t).destroy_all
    if player.scores_in_game(game).pluck(:value).max > 9
        Performance.create(:game=>game,:player=>player, :trophy=>t)
        return true
    end
    return false
  end
  
  def self.unlock_after_2_pm(game,player)
    t=Trophy.find_by_technical_name('after_2_pm')
    Performance.where(:game=>game,:player=>player, :trophy=>t).destroy_all
    h=game.rounds.order(:created_at).last.created_at.time.hour
    if h >= 12 && h<14 
        Performance.create(:game=>game,:player=>player, :trophy=>t)
        return true
    end
    return false
  end
  
  def self.unlock_boring(game, player)
    t=Trophy.find_by_technical_name('boring')
    p_result=Result.for_game_and_player(game, player)
    p2_total_score=game.results.where(:ranking=>2).first.try(:total_score)
    if p2_total_score.nil?
      Performance.where(:game=>game,:player=>player, :trophy=>t).destroy_all
      return false
    end
    if p_result.ranking==1 && (p_result.total_score - p2_total_score > 14)
        p=Performance.where(:game=>game,:player=>player, :trophy=>t).first_or_initialize
        p.save
        return true
    else
        Performance.where(:game=>game,:player=>player, :trophy=>t).destroy_all
        return false
    end
  end
  
  def self.unlock_dix_cafes(game, player)
    t=Trophy.find_by_technical_name("dix_cafes")
    return false if t.nil?
    if Performance.where(:player=>player, :trophy=>t).blank? && player.nb_payed_coffees_all_time > 10
        Performance.create(:game=>game,:player=>player, :trophy=>t)
        return true
    else
        return false
    end
  end
  def self.unlock_cent_cafes(game, player)
    t=Trophy.find_by_technical_name("cent_cafes")
    return false if t.nil?
    if Performance.where(:player=>player, :trophy=>t).blank? && player.nb_payed_coffees_all_time > 100
        Performance.create(:game=>game,:player=>player, :trophy=>t)
        return true
    else
        return false
    end
  end
  
  def self.unlock_back_2_back(game, player)
    t=Trophy.find_by_technical_name('back_2_back')
    Performance.where(:game=>game,:player=>player, :trophy=>t).destroy_all
    if Result.for_game_and_player(game, player).ranking==1
      prevgame=player.games.order(:created_at).where("created_at < ?",game.created_at).try(:last)
      if Result.for_game_and_player(prevgame, player).try(:ranking)==1
        return false if Performance.where(:game=>prevgame,:player=>player, :trophy=>t).present?
        p=Performance.where(:game=>game,:player=>player, :trophy=>t).first_or_initialize
        p.save
        return true
      end
    end
    return false
  end
  def self.unlock_back_3_back(game, player)
    t=Trophy.find_by_technical_name('back_3_back')
    Performance.where(:game=>game,:player=>player, :trophy=>t).destroy_all
    if Result.for_game_and_player(game, player).ranking==1
      prevgame=player.games.order(:created_at).where("created_at < ?",game.created_at).try(:last)
      # raise prevgame.inspect
      if Result.for_game_and_player(prevgame, player).try(:ranking)==1
        prevgame2=player.games.order(:created_at).where("created_at < ?", prevgame.created_at).try(:last)
        if Result.for_game_and_player(prevgame2, player).try(:ranking)==1
          p=Performance.where(:game=>game,:player=>player, :trophy=>t).first_or_initialize
          p.save
          return true
        end
      end
    end
    return false
  end
  
  
  { "bienvenue" => 2, "debutant" => 10, "competent" => 30, "expert" => 50, "master" => 100 }.each do |techname, threshold|
    define_singleton_method("unlock_#{techname}") do |game, player|
      t=Trophy.find_by_technical_name(techname)
      return false if t.nil?
      if Performance.where(:player=>player, :trophy=>t).present?
          # il a deja le trophée
          return false
      elsif player.results.count==threshold
          Performance.create(:game=>game,:player=>player, :trophy=>t)
          return true
      else
          return false
      end
    end
  end
    
  def self.unlock_ca_partage(game, player)
    t=Trophy.find_by_technical_name('ca_partage')
    puts "======>"+Result.where(:game=>game, :ranking => 1).count.inspect 
    if Result.for_game_and_player(game, player).ranking==1 && (Result.where(:game=>game, :ranking => 1).count > 1) 
        p=Performance.where(:game=>game,:player=>player, :trophy=>t).first_or_initialize
        p.save
        return true
    else
        Performance.where(:game=>game,:player=>player, :trophy=>t).destroy_all
        return false
    end
  end
    
  def self.unlock_tout_ca_pour_ca(game,player)
    t=Trophy.find_by_technical_name('tout_ca_pour_ca')
    if Result.for_game_and_player(game, player).total_score==0
        p=Performance.where(:game=>game,:player=>player, :trophy=>t).first_or_initialize
        p.save
        return true
    else
        Performance.where(:game=>game,:player=>player, :trophy=>t).destroy_all
        return false
    end
  end
  
  def self.unlock_jacques_mayol(game,player)
    t=Trophy.find_by_technical_name('jacques_mayol')
    if game.scores.where(:player=>player).pluck(:tmp_total).any?(&:positive?) == false
      p=Performance.where(:game=>game,:player=>player, :trophy=>t).first_or_initialize
      p.save
      return true
    else
      Performance.where(:game=>game,:player=>player, :trophy=>t).destroy_all
      return false
    end
  end
  def self.unlock_chalumeau(game,player)
    t=Trophy.find_by_technical_name('chalumeau')
    ar=game.scores.where(:player=>player).pluck(:value)
    chalum=false
    ar.each_cons(5) { |cons| chalum=cons.all?{|val| val == -1}if chalum==false } 
    if chalum
      p=Performance.where(:game=>game,:player=>player, :trophy=>t).first_or_initialize
      p.save
      return true
    else
      Performance.where(:game=>game,:player=>player, :trophy=>t).destroy_all
      return false
    end
  end
  
  def self.unlock_carambolage(game,player)
    return false if game.players.count<4
    t=Trophy.find_by_technical_name('carambolage')
    car=false
    game.rounds.each do |r|
      car=true if r.scores.pluck(:value).all?{|sc| sc < 1}
    end
    if car
      p=Performance.where(:game=>game,:player=>player, :trophy=>t).first_or_initialize
      p.save
      return true
    else
      Performance.where(:game=>game,:player=>player, :trophy=>t).destroy_all
      return false
    end
  end 
  
  def self.unlock_glacons(game,player)
    return false unless game.losers.include? player
    return false if game.losers.count > 1
    t=Trophy.find_by_technical_name('glacons')
    loser_result=Result.for_game_and_player(game, player)
    second_loser_result=Result.where(:game=>game, :ranking=>loser_result.ranking-1).first
    if (loser_result.nil? || second_loser_result.nil?)
      puts "##################"
      puts "###TRUC BIZARRE###"
      puts "##################"
      puts "sur la partie #{game.id}"
      puts "dans la boucle du joueur #{player.name}"
      puts "LOSER RESULT est NIL" if loser_result.nil?
      puts "SECOND LOSER RESULT est NIL" if second_loser_result.nil?
      puts "##################"
      return false 
    end
    if (second_loser_result.total_score - loser_result.total_score) >=15
      p=Performance.where(:game=>game,:player=>player, :trophy=>t).first_or_initialize
      p.save
      return true
    else
      Performance.where(:game=>game,:player=>player, :trophy=>t).destroy_all
      return false
    end
  end
  
  def self.unlock_collectionneur(game, player)
    t=Trophy.find_by_technical_name('collectionneur')
    if player.performances.pluck(:trophy_id).uniq.count >= 10
      return false if Performance.where(:player=>player, :trophy=>t).present?
      p=Performance.where(:game=>game,:player=>player, :trophy=>t).first_or_initialize
      p.save
      return true
    else
      Performance.where(:game=>game,:player=>player, :trophy=>t).destroy_all
      return false
    end
  end
  
end
