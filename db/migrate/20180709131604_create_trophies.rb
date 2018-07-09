class CreateTrophies < ActiveRecord::Migration[5.1]
  def change
    create_table :trophies do |t|
      t.string :name
      t.string :technical_name
      t.text :description

      t.timestamps
    end
  end
end
