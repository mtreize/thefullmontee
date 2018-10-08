class AddGifurlToTrophy < ActiveRecord::Migration[5.1]
  def change
    add_column :trophies, :gifurl, :string
  end
end
