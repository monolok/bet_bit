class CreateClients < ActiveRecord::Migration[5.0]
  def change
    create_table :clients do |t|
      t.string :bet_address
      t.string :client_address
      t.integer :bet_id
      t.boolean :status, default: false
      t.boolean :up, default: false
      t.boolean :down, default: false

      t.timestamps
    end
  end
end
