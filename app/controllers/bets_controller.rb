class BetsController < ApplicationController

require 'block_io'
BlockIo.set_options :api_key=> '6b38-5f0e-3058-24c2', :pin => 'SECRET PIN', :version => 2  

  def index
  	@bets = Bet.all.order( 'id DESC' )
  	@bet_last = Bet.last
  end

  def arrow_up
  	@client_address = params["parameter"]
	#@bet_address = BlockIo.get_new_address(:label => @client_address)
  	
  	#render json: @bet_address
  end

  def arrow_down
  	@client_address = params["parameter"]
	#@bet_address = BlockIo.get_new_address(:label => @client_address)
  	
  	#render json: @bet_address
  end
#private

	# def bet_params
	# 	params.require(:bet).permit(:base_price)	
	# end


end
