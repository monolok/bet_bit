class AddResultToBets < ActiveRecord::Migration[5.0]
  def change
    add_column :bets, :result, :string
  end
end
