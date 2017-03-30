class BetsController < ApplicationController

  def index
    @bets = Bet.all.order( 'id DESC' )
  	@bet_last = Bet.last


    Time.now.hour
    Time.now.min 
    @bet_last.created_at.hour 
    @bet_last.created_at.min

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

  def status
    @client_address_status = params["parameter"]
    @status = BlockIo.get_address_balance :addresses => @client_address_status

    #when AJAX success render json hash of status
    render json: @status
  end

#private

	# def bet_params
	# 	params.require(:bet).permit(:base_price)	
	# end


end