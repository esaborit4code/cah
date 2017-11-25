class CreateQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :questions do |t|
      t.string :text
      t.integer :gaps
      t.integer :round, default: nil

      t.timestamps
    end
  end
end
