class AddNumberToRound < ActiveRecord::Migration[5.1]
  def change
    add_column :rounds, :number, :integer
  end
end
