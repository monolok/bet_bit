class BetsController < ApplicationController
  def index
  	@kraken_btc_eur = HTTParty.get("https://api.kraken.com/0/public/Ticker?pair=XXBTZEUR")["result"]["XXBTZEUR"]["c"][0].to_f.round(2)
  	@bets = Bet.all
  	@bet_last = Bet.last
  end

  def create
  	@bet = Bet.new
  	@bet.base_price = params["parameter"]
  	@bet.save  
  	Bet.first.destroy

  	@bets = Bet.all
  	@bet_last = Bet.last
	
	render json: @bet
	#render :js => "window.location = '#{root_path}'"
  	#redirect_to "index"
  	#render :inline => "<% @bets.each do |b| %><p><%= b.id %><p><% end %>"

  end

#private

	# def bet_params
	# 	params.require(:bet).permit(:base_price)	
	# end


end
