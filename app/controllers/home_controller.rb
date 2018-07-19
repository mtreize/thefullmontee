class HomeController < ApplicationController
    def index
        # @unfinished_games=Game.where("created_at > ?", Time.now-1.day).order(:created_at).reject{|g| g.is_finished?}.last(3)
        @unfinished_games=Game.order(:created_at).reject{|g| g.is_finished?}.last(3)
    end    
    
    def dashboard
        @still_locked_trophies=Trophy.active.where.not(:id=>Performance.all.pluck(:trophy_id).uniq)
    end
end
