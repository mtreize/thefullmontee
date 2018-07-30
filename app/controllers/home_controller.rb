class HomeController < ApplicationController
  include ApplicationHelper

    def index
        # @unfinished_games=Game.where("created_at > ?", Time.now-1.day).order(:created_at).reject{|g| g.is_finished?}.last(3)
        @unfinished_games=Game.order(:created_at).reject{|g| g.is_finished?}.last(3)
    end    
    
    def dashboard
        #############
        groupcount= Performance.all.group(:player_id).count
        l=groupcount.keys.map{|pid|Player.find(pid).name}
        d=groupcount.values
        
        @perf_by_player_data = {
            datasets: [{ data: d, backgroundColor: color_array_for_stats_graphs}], 
            labels: l
        }
        @perf_by_player_options = { }
        
        #############
        @still_locked_trophies=Trophy.active.where.not(:id=>Performance.all.pluck(:trophy_id).uniq)
        l=["Trophée déjà débloqués", "Trophée jamais débloqués"]
        d=[(Trophy.active.count-@still_locked_trophies.count), @still_locked_trophies.count]
        @unlocked_trophies_data = {
            datasets: [{ data: d, backgroundColor: color_array_for_stats_graphs}], 
            labels: l
        }
        @unlocked_trophies_options = { }
        #############
        diff={}
        diff2={}
        kfbus=[]
        kfpayes=[]
        Player.all.order(:id).reject{|p| p.games.count==0}.each do |p|
            kfbus << p.games.count
            kfpayes << p.nb_payed_coffees_all_time
            diff[p.name] = p.games.count-p.nb_payed_coffees_all_time
        end
        diff2=diff
        @rentables=diff2.select{|key, val| val == diff.max_by{|k,v| v}.second}
        @pasrentables=diff2.select{|key, val| val == diff.min_by{|k,v| v}.second}
        @kf_ratio_data ={
			labels: diff.keys,
			datasets: [{
				label: 'Différence : Cafés Bus - Cafés payés',
				borderColor: "#18A2B8",
				backgroundColor: "#18A2B8",
				fill: false,
				data: diff.values,
				type: 'line'
			}, {
				label: 'Cafés Bus',
				backgroundColor: "#4792DB",
				data: kfbus
			}, {
				label: 'Cafés payés',
				backgroundColor: "#915B87",
				data: kfpayes
			}]

		}
        @kf_ratio_options = { height: 150,
            elements: {
                line: {
                    tension: 0
                }
            }
        }
        ######

        c=Game.all.order(:id).map{|g| "A #{g.players.count} joueurs"}
        c2=Hash[c.uniq.map{ |i| [i, c.count(i)] }]
        @player_by_game_data = {
            datasets: [{ data: c2.values, backgroundColor: color_array_for_stats_graphs}], 
            labels: c2.keys
        }
        @player_by_game_options = { }
        ######

        perfs=Trophy.where(:technical_name=>"victory").first.performances.map{|p| p.player.name}
        perfs2=Hash[perfs.uniq.map{ |i| [i, perfs.count(i)] }]
        @victories_by_player_data = {
            datasets: [{ data: perfs2.values, backgroundColor: color_array_for_stats_graphs}], 
            labels: perfs2.keys
        }
        @victories_by_player_options = { }
        
    end
end
