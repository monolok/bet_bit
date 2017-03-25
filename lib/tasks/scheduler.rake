require 'block_io'
BlockIo.set_options :api_key=> 'bccd-bae8-44bc-a249', :pin => 'toines2875', :version => 2  


# desc "testing"
# task :bet => :environment do
# 	@bet_to_test = Bet.last
# 	i = 0
# 	while i < @bet_to_test.clients.count do
# 		balance = BlockIo.get_address_balance :addresses => @bet_to_test.clients[i].bet_address
# 		if balance["data"]["available_balance"].to_f > 0 || balance["data"]["pending_received_balance"].to_f > 0
# 			puts "Client #{@bet_to_test.clients[i].id} status needs an update"
# 		end
# 		i+=1
# 	end
# 	puts "testing done."
# end



####################SET MINIMUM BET, network fee + comm + GIT IGNORE FOR ENV DATA



desc "New/close/clean bets (cron: 5 min)"
task :bet => :environment do
	
	#creating current bet
	puts "creating current bet..."
	@kraken_btc_eur = HTTParty.get("https://api.kraken.com/0/public/Ticker?pair=XXBTZEUR")["result"]["XXBTZEUR"]["c"][0].to_f.round(2)	
	@bet = Bet.new
	@bet.base_price = @kraken_btc_eur
	@bet.status = "Active"
	@bet.save
	puts "current bet #{@bet.id} created."

	#update client status(paid or not, true/false)
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
				puts "Client #{@bet_to_update_clients.clients[i].id} status updated"
			end
			i+=1
		end
		puts "clients status updated from bet #{@bet_to_update_clients.id}."
	else
		puts "no bet with clients to update."
	end
		
	#closing bet with its result and updated status
	puts "closing bet..."
	if Bet.all.count >= 4
		@bet_to_close_id = (Bet.last.id) - 3
		@bet_to_close = Bet.find(@bet_to_close_id)
		if @kraken_btc_eur > @bet_to_close.base_price 
			@bet_to_close.update(last_price: @kraken_btc_eur, status: "Closed", result: "up")
		else
			@bet_to_close.update(last_price: @kraken_btc_eur, status: "Closed", result: "down")
		end
		puts "bet #{@bet_to_close_id} closed."
	else
		puts "no bet to close."
	end

	#determine winners and money to payout from the loosers
	if Bet.exists?(@bet_to_close_id) == true && @bet_to_close.clients.any? == true
		@winners = @bet_to_close.clients.where("#{@bet_to_close.result}": true, status: true)
		@loosers = @bet_to_close.clients.where("#{@bet_to_close.result}": false, status: true)
		if @loosers.count == 0
			puts "no loosers"
			i = 0
			#if no loosers refund each winner
			while i < @winners.count 
				balance_hash = BlockIo.get_address_balance :addresses => @winners[i].bet_address
				balance = balance_hash["data"]["available_balance"].to_f
				BlockIo.withdraw :amounts => "#{balance}", :to_addresses => "#{@winners[i].client_address}"
				i+=1
				puts "refunding #{balance} to client #{@winners[i].id}"
			end
		elsif @winners == 0
			puts "no winners"
		else
			#sum of bitcoins from all loosers
			i = 0
			@funds_loosers = Array.new
			while i < @loosers.count
				balance_hash = BlockIo.get_address_balance :addresses => @loosers[i].bet_address
				balance = balance_hash["data"]["available_balance"].to_f
				@funds_loosers << balance
				i+=1
			end
			@loosers_sum = @funds_loosers.inject(:+)
			puts "sum to payout is #{@loosers_sum}"

			#sum of winner btc to dermine % to distribute
			y = 0
			@funds_winners = Hash.new
			@win_sum = Array.new
			while y < @winners.count
				balance_hash = BlockIo.get_address_balance :addresses => @winners[y].bet_address
				balance = balance_hash["data"]["available_balance"].to_f
				@funds_winners["@winners[y].id"] = balance
				@win_sum << balance
				y+=1
			end
			@winners_sum = @win_sum.inject(:+)
			puts "sum of winners is #{@winners_sum}"

			#pay out winners based on % of their bet
			z = 0
			while z < @winners.count
				won = (@funds_winners.key(@winners[z].id).to_f / @winners_sum) * @loosers_sum
				puts "paying #{won} to #{@winners[z].client_address}"
				BlockIo.withdraw :amounts => "#{won}", :to_addresses => "#{@winners[z].client_address}"
				z+=1
			end
		end
	end

	#cleaning the history table
	puts "cleaning bet history table..."
	if Bet.all.count > 6
		@bet_to_destroy = Bet.first		
		#Destory btc addresses associated with the bet_to_destroy
		if @bet_to_destroy.clients.count > 0
			u = 0
			while u > @bet_to_destroy.clients.count
				BlockIo.archive_addresses :addresses => "#{@bet_to_destroy.clients[u].bet_address}"
				u+=1
			end
		end
  		#destroy the oldest bet along with its associated clients if any
  		@bet_to_destroy.destroy	
  		puts "Table cleaned and related btc address deleted"
  	else
  		puts "no bet deleted, < 10 bets."
  	end
#end of task
end