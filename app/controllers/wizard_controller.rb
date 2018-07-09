class WizardController < ApplicationController
    
    def game_step_0
        
    end
    
    def game_step_1
        #on garde l'orodre des clics pour les positions => possible, checke les params ;)
        #raise params.inspect
        @players=Player.where(:id=> params[:players_ids])
        @players_count=@players.count
        
        @game=Game.new
        @game.players=@players
        @game.location=params[:location]
        @game.save
        
        @round=Round.new
        @round.game=@game
        @round.number=1
        @round.save
    end
    
end
