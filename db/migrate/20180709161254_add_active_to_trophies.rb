class AddActiveToTrophies < ActiveRecord::Migration[5.1]
  def change
    add_column :trophies, :active, :boolean
  end
end
