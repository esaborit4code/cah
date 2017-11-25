class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :players do |t|
      t.string :name
      t.integer :role, default: 0
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
