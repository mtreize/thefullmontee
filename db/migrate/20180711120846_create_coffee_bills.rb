class CreateCoffeeBills < ActiveRecord::Migration[5.1]
  def change
    create_table :coffee_bills do |t|
      t.references :player, foreign_key: true
      t.references :game, foreign_key: true
      t.integer :nb_coffee

      t.timestamps
    end
  end
end
