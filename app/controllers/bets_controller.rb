class BetsController < ApplicationController
  def index
  	@kraken_btc_eur = HTTParty.get("https://api.kraken.com/0/public/Ticker?pair=XXBTZEUR")["result"]["XXBTZEUR"]["c"][0].to_f.round(2)
  	@bets = Bet.all
  	@bet_last = Bet.last
  	
  end
end
