class AddTmpTotalToScore < ActiveRecord::Migration[5.1]
  def change
    add_column :scores, :tmp_total, :integer
  end
end
