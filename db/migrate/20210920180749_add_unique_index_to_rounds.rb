class AddUniqueIndexToRounds < ActiveRecord::Migration[6.1]
  def change
    add_index :rounds, [:number, :player_id, :game_id], unique: true
  end
end
