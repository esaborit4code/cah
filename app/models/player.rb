class Player < ApplicationRecord
  enum role: [:player, :tzar, :random]
  enum status: [:in, :out]

  scope :human, -> { where.not(role: :random) }
end
