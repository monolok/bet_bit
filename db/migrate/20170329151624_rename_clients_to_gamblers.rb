class RenameClientsToGamblers < ActiveRecord::Migration[5.0]
  def change
  	rename_table :clients, :gamblers
  end
end
