Rails.application.routes.draw do
	root "bets#index"
	get "/index", to: "bets#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
