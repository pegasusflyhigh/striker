class CreateRounds < ActiveRecord::Migration[6.1]
  def change
    create_table :rounds do |t|
      t.integer :number
      t.text :score, array: true, default: []

      t.timestamps
    end
  end
end
