class AddReferences < ActiveRecord::Migration[6.1]
  def change
    add_reference :rounds, :player, foreign_key: true
    add_reference :rounds, :game, foreign_key: true
    add_reference :players, :game, foreign_key: true
    add_column :rounds, :previous_id, :integer, null: true, index: true
    add_foreign_key :rounds, :rounds, column: :previous_id
  end
end
