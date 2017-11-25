class Player < ApplicationRecord
  enum role: [:player, :tzar, :random]
  enum status: [:in, :out]

  has_many :answers

  scope :human, -> { where.not(role: :random) }

  def score
    answers.count(&:winner?)
  end
end
