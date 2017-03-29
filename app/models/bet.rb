class Bet < ApplicationRecord
	has_many :gamblers, dependent: :destroy
end
