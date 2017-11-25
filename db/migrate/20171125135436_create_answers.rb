class CreateAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :answers do |t|
      t.string :text
      t.references :player, null: true
      t.references :question, null: true
      t.boolean :winner, default: false

      t.timestamps
    end
  end
end
