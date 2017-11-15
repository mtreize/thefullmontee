class Game < ApplicationRecord
    has_and_belongs_to_many :players
    has_many :rounds, dependent: :destroy
    has_many :scores, :through=>:rounds
    after_save :generate_title
    
    
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
        when 0..6 then "Nuit"
        when 7..11 then "Matin"
        when 12..14 then "Midi"
        when 15..16 then "Aprem"
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
    
end
