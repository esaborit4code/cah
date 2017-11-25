class Answer < ApplicationRecord
  belongs_to :player, optional: true
  belongs_to :question, optional: true

  scope :unused, -> { where(question: nil) }
end
