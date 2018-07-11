class CoffeeBill < ApplicationRecord
  belongs_to :player
  belongs_to :game
  
  def self.create_or_update_bill_for_gameid_and_playerid_and_coffeenumber(gameid, playerid, nb_coffees)
    bill=CoffeeBill.where(:game_id=>gameid, :player_id=>playerid).first_or_initialize
    bill.nb_coffee=nb_coffees
    bill.save
  end
  def self.erase_all_bills_for_game(game)
    CoffeeBill.where(:game=>game).destroy_all
  end
end
