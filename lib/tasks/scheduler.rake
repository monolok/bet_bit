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

	#closing bet
	puts "closing bet..."
	if Bet.all.count > 4
		@bet_to_close_id = (Bet.last.id) - 3
		@bet_to_close = Bet.update(@bet_to_close_id, last_price: @kraken_btc_eur, status: "Closed")
		puts "bet closed."
	else
		puts "no bet to close."
	end

	#cleaning the history table
	puts "cleaning bet history table"
	if Bet.all.count > 10
  	Bet.first.destroy
  	puts "Table cleaned."
  else
  	puts "no bet deleted, < 10 bets"
  end

end


desc "testing btc address create"
task :btc => :environment do 
	BlockIo.get_new_address(:label => 'shibe1')
end
