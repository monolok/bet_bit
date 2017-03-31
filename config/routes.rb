Rails.application.routes.draw do
	root "bets#index"
	get "/up", to: "bets#arrow_up"
	get "/down", to: "bets#arrow_down"
	get "/status", to: "bets#status"
	get "/current_btc", to: "bets#current_btc"
end
