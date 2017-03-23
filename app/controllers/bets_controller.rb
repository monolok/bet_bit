class BetsController < ApplicationController

require 'block_io'
BlockIo.set_options :api_key=> '6b38-5f0e-3058-24c2', :pin => 'toines2875', :version => 2  

  def index
  	@bets = Bet.all.order( 'id DESC' )
  	@bet_last = Bet.last
  end

  def arrow_up
  	@client_address = params["parameter"]
  	@client = Client.new
  	@client.client_address = @client_address
  	@client.bet_id = Bet.last.id
  	@client.up = true
  	@client.save
  	@bet_address = BlockIo.get_new_address(:label => "#{@client.id}")
  	@client.update(bet_address: @bet_address["data"]["address"])
  	
  	#When payment received update status to true
  	render json: @client
  end

  def arrow_down
  	@client_address = params["parameter"]
  	@client = Client.new
  	@client.client_address = @client_address
  	@client.bet_id = Bet.last.id
  	@client.down = true
  	@client.save
	  @bet_address = BlockIo.get_new_address(:label => "#{@client.id}")
  	@client.update(bet_address: @bet_address["data"]["address"])

  	#When payment received update status to true
  	render json: @client
  end
#private

	# def bet_params
	# 	params.require(:bet).permit(:base_price)	
	# end


end