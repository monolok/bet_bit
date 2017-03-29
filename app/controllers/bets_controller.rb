class BetsController < ApplicationController

  def index
    @kraken = KrakenClient.load
    @kraken_time = @kraken.public.server_time.rfc1123
  	@bets = Bet.all.order( 'id DESC' )
  	@bet_last = Bet.last
  end

  def arrow_up
  	@client_address = params["parameter"]
  	@client = Gambler.new
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
  	@client = Gambler.new
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