class CreateRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :records do |t|
      t.string :name
      t.string :description
      t.references :player, foreign_key: true
      t.references :game, foreign_key: true
      t.string :comment
      t.integer :value

      t.timestamps
    end
  end
end
