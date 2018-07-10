class Trophy < ApplicationRecord
    scope :active, -> { where(active: true) }

    
    
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

    
end
