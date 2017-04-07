class BetsController < ApplicationController

  def index
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

  def status
    @client_address_status = params["parameter"]
    @status = BlockIo.get_address_balance :addresses => @client_address_status
    @gambler_id = @status["data"]["balances"][0]["label"]
    @gambler = Gambler.find(@gambler_id)
    @gambler_bet = Bet.find(@gambler.bet_id)

    @json_hash = {}
    @json_hash["BlockIo"] = @status
    @json_hash["Gambler"] = @gambler
    @json_hash["Bet"] = @gambler_bet


    #when AJAX success render json hash of status
    render json: @json_hash
  end

  def current_btc
    @current_bet = Bet.last
    @up = []
    @down = []

    
    i = 0
    while i < @current_bet.gamblers.where.not(bet_address: nil).count do
      balance = BlockIo.get_address_balance :addresses => @current_bet.gamblers[i].bet_address
      if balance["data"]["available_balance"].to_f > 0 || balance["data"]["pending_received_balance"].to_f > 0
        if @current_bet.gamblers[i].up == true
            @up << balance["data"]["available_balance"].to_f
            @up << balance["data"]["pending_received_balance"].to_f
        else
            @down << balance["data"]["available_balance"].to_f
            @down << balance["data"]["pending_received_balance"].to_f
        end
      end
      i+=1
    end

    if @up.empty?
      @sum_up = 0
    else
      @sum_up = @up.inject(:+)
    end
    
    if @down.empty?
      @sum_down = 0
    else
      @sum_down = @down.inject(:+)
    end

    if @up.empty? && @down.empty?
      @sum = 0
    else
      @sum = @sum_up + @sum_down
    end

    @sums = {}  
    @sums["up"] = @sum_up
    @sums["down"] = @sum_down
    @sums["total"] = @sum

    render json: @sums
  end

  def sending
    @subject = params["subject"]
    @text = params["message"]
    ContactMailer.send_contact(@subject, @text).deliver_now
    flash[:notice] = "Mail sent"
    redirect_to root_path
  end
#private

	# def bet_params
	# 	params.require(:bet).permit(:base_price)	
	# end


end