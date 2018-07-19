class AddPositiveToTrophy < ActiveRecord::Migration[5.1]
  def change
    add_column :trophies, :positive, :integer
  end
end
