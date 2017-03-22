class Bet < ApplicationRecord
	has_many :clients, dependent: :destroy
end
