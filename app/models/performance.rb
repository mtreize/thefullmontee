class Performance < ApplicationRecord
  belongs_to :player
  belongs_to :trophy
  belongs_to :game
end
