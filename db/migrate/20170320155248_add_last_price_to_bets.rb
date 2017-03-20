class AddLastPriceToBets < ActiveRecord::Migration[5.0]
  def change
    add_column :bets, :last_price, :decimal
  end
end
