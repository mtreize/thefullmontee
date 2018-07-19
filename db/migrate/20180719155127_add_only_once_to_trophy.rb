class AddOnlyOnceToTrophy < ActiveRecord::Migration[5.1]
  def change
    add_column :trophies, :only_once, :integer
  end
end
