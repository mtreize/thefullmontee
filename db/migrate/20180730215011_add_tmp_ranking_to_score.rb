class AddTmpRankingToScore < ActiveRecord::Migration[5.1]
  def change
    add_column :scores, :tmp_ranking, :integer
  end
end
