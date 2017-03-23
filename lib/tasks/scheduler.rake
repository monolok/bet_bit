require 'block_io'
BlockIo.set_options :api_key=> '6b38-5f0e-3058-24c2', :pin => 'SECRET PIN', :version => 2  

desc "New/close/clean bets (cron: 5 min)"
task :bet => :environment do
	
	#creating current bet
	puts "creating current bet..."
	@kraken_btc_eur = HTTParty.get("https://api.kraken.com/0/public/Ticker?pair=XXBTZEUR")["result"]["XXBTZEUR"]["c"][0].to_f.round(2)	
	@bet = Bet.new
	@bet.base_price = @kraken_btc_eur
	@bet.status = "Active"
	@bet.save
	puts "current bet created."

	#update client status(paid or not, true/false) for the bet to be closed after the one closing now
	puts "Updating client status..."
	if Bet.all.count >= 4
		@bet_to_update_clients_id = (Bet.last.id) - 2
		@bet_to_update_clients = Bet.find(@bet_to_update_clients_id)
		#check for clients payments and update their status accordingly
		i = 0
		while i < @bet_to_update_clients.clients.count do
			balance = BlockIo.get_address_balance :addresses => @bet_to_update_clients.clients[i].bet_address
			if balance["data"]["available_balance"].to_f > 0 || balance["data"]["pending_received_balance"].to_f > 0
				@bet_to_update_clients.clients[i].update(status: true)
			end
			i+=1
		end
		puts "clients status updated."
	else
		puts "no bet with clients to update."
	end
		
	#closing bet and paying clients
	puts "closing bet..."
	if Bet.all.count >= 4
		@bet_to_close_id = (Bet.last.id) - 3
		@bet_to_close = Bet.find(@bet_to_close_id)
		if @kraken_btc_eur > @bet_to_close.base_price 
			@bet_to_close.update(last_price: @kraken_btc_eur, status: "Closed", result: "up")
		else
			@bet_to_close.update(last_price: @kraken_btc_eur, status: "Closed", result: "down")
		end
		puts "bet closed."
	else
		puts "no bet to close."
	end

	#cleaning the history table
	puts "cleaning bet history table..."
	if Bet.all.count > 10
  		Bet.first.destroy
  		puts "Table cleaned."
  	else
  		puts "no bet deleted, < 10 bets."
  	end

#end of task
end