class CreatePerformances < ActiveRecord::Migration[5.1]
  def change
    create_table :performances do |t|
      t.references :player, foreign_key: true
      t.references :trophy, foreign_key: true
      t.references :game, foreign_key: true

      t.timestamps
    end
  end
end
