class BetsController < ApplicationController
  def index
  	flash[:kraken] = KrakenJob.perform_async
  	@bet_last = Bet.last
  	@bets = Bet.all
  end
end
