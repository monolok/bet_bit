class BetsController < ApplicationController
  def index
  	@bets = Bet.all.order( 'id DESC' )
  	@bet_last = Bet.last
  end

#private

	# def bet_params
	# 	params.require(:bet).permit(:base_price)	
	# end


end
