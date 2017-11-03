class Score < ApplicationRecord
  belongs_to :player
  belongs_to :round
  validates_uniqueness_of :player, :scope => :round

end
