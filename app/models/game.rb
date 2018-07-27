class Game < ApplicationRecord
    has_and_belongs_to_many :players
    has_many :rounds, dependent: :destroy
    has_many :scores, :through=>:rounds
    after_save :generate_title
    scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }
    
    has_many :results, :dependent => :destroy
    has_many :coffee_bills, :dependent => :destroy
    has_many :performances, :dependent => :destroy

    include ActionView::Helpers
    #def gametime
    #  return 0 if self.results.first.nil?
    #  distance_of_time_in_words(self.results.first.created_at, self.created_at)
    #end
    #def gametime_maths
    #  return 0 if self.results.first.nil? 
    #  self.results.first.created_at.to_i - self.created_at.to_i
    #end
    def gametime
      "#{self.gametime_maths/60} minutes"
    end
    def gametime_maths
      return 0 if self.scores.last.nil? 
      self.scores.last.created_at.to_i - self.created_at.to_i
    end
    def rules
        case self.players.count
            when 2
              "26 manches : De 1 à 26 cartes"
            when 3
              "17 manches : De 1 à 17 cartes"
            when 4
              "13 manches : De 1 à 13 cartes"
            when 5
              "12 manches : De 1 à 9 cartes puis 3x 10 cartes"
            when 6
              "12 manches : [2 fois] De 5 à 10 cartes - 1 mort"
            when 7
              "14 manches : [2 fois] De 4 à 10 cartes - 2 morts"
            else
              "Annulez tout et faites deux tables."
        end
    end
    def nb_rounds
      case self.players.count
        when 2
          26
        when 3
          17
        when 4
          13
        when 5, 6
          12
        when 7
          14
        else
          0
      end
    end
    def nb_scores_needed
        self.nb_rounds * self.players.count
    end
    def nb_cards_for_round(round_number)
      nbplayers=self.players.count
      case nbplayers
        when 2,3,4
          round_number
        when 5
          round_number>=10 ? 10 : round_number
        when 6,7
          res=round_number+(10-nbplayers)
          res>10 ? res-nbplayers : res
        else
          nil
      end
    end
    def generate_title
      d=I18n.l(self.created_at, format: '%a %d %b').titleize
      h=I18n.l(self.created_at, format: '%H').to_i
      daypart= case h
        when 0..4 then "Nuit"
        when 5..9 then "Matin"
        when 10..13 then "Midi"
        when 14..16 then "Aprem"
        when 17..23 then "Soir"
        else "wtf "+h.to_s
      end
      
      titl=d+" - "+daypart
      
      if Game.where(:title=>titl).where.not(:id=> self.id).blank?
        title=titl
      else
        title=titl+" [#{self.id}]"
      end
      
      
      self.update_column(:title, title)
    end
    def is_finished?
      self.scores.count == self.nb_scores_needed
    end
    def recap_image_path
      "/games_graphs/game_#{self.id}.png"
    end
    
    def compute_results
      scores={}
      self.players.each do |p|
        scores[p.id]= p.scores_in_game(self).pluck(:value).sum
      end
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
      self.results.destroy_all
      self.players.each do |p|
        r=Result.where(:player=>p, :game=>self).first_or_initialize
        r.total_score = scores[p.id]
        r.ranking = rankings[p.id]
        r.save
      end
    end
    
    def compute_performances
      return nil unless self.is_finished?
      specials_trophies=["collectionneur"]
      self.compute_results
      self.calculate_coffees
      something_unlocked=false
      self.players.each do |p|
        Trophy.active.each do |trophy|
          unless specials_trophies.include? trophy.technical_name
            if Trophy.send("unlock_#{trophy.technical_name}", self, p)
              something_unlocked=true
            end
          end
        end
        Trophy.unlock_collectionneur(self,p)
      end
      return something_unlocked
    end
    
    def calculate_coffees
      CoffeeBill.erase_all_bills_for_game(self)
      
      results= self.results.order(:total_score)
      case self.players.count
        when 2
          if results.first.ranking==results.second.ranking
            results.first(2).pluck(:player_id).each do |pid|
              CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, pid, 1)
            end
          else
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.first.player.id, self.players.count)
          end
          
        when 3
          if results.first.ranking==results.second.ranking
            if results.second.ranking==results.third.ranking
              results.first(3).pluck(:player_id).each do |pid|
                CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, pid, 1)
              end
            else
              results.first(2).pluck(:player_id).each do |pid|
                CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, pid, 1)
              end
            end
          else
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.first.player.id, self.players.count)
          end
          
        when 4
          if results.first.ranking==results.second.ranking
            if results.second.ranking==results.third.ranking
              results.first(3).pluck(:player_id).each do |pid|
                CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, pid, 1)
              end
            else
              results.first(2).pluck(:player_id).each do |pid|
                CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, pid, 2)
              end
            end
          else
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.first.player.id, self.players.count)
          end
          
        when 5
          
          if results.first.ranking==results.second.ranking
            if results.second.ranking==results.third.ranking
              results.first(3).pluck(:player_id).each do |pid|
                CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, pid, 2)
              end
            else
              results.first(2).pluck(:player_id).each do |pid|
                CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, pid, 3)
              end
            end
          elsif results.second.ranking==results.third.ranking
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.first.player_id, 3)
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.second.player_id, 1)
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.third.player_id, 1)
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.fourth.player_id, 1) if results.third.ranking==results.fourth.ranking
          else
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.first.player.id, 3)
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.second.player.id, 2)
          end
          
        when 6
          
          if results.first.ranking==results.second.ranking
            if results.second.ranking==results.third.ranking
              results.first(3).pluck(:player_id).each do |pid|
                CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, pid, 2)
              end
            else
              results.first(2).pluck(:player_id).each do |pid|
                CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, pid, 3)
              end
            end
          elsif results.second.ranking==results.third.ranking
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.first.player_id, 4)
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.second.player_id, 1)
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.third.player_id, 1)
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.fourth.player_id, 1) if results.third.ranking==results.fourth.ranking
          else
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.first.player.id, 4)
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.second.player.id, 2)
          end
          
        when 7          
          if results.first.ranking==results.second.ranking
            if results.second.ranking==results.third.ranking
              results.first(3).pluck(:player_id).each do |pid|
                CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, pid, 2)
              end
            else
              results.first(2).pluck(:player_id).each do |pid|
                CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, pid, 3)
              end
            end
          elsif results.second.ranking==results.third.ranking
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.first.player_id, 4)
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.second.player_id, 2)
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.third.player_id, 2)
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.fourth.player_id, 2) if results.third.ranking==results.fourth.ranking
          else
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.first.player.id, 4)
            CoffeeBill.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(self.id, results.second.player.id, 3)
          end
          
        else
          0
      end
    end
    
end
