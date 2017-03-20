Rails.application.routes.draw do
	root "bets#index"
	#get "/bets", to: "bets#index"
	#post "/bets", to: "bets#create"
	
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
