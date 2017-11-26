module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_player

    def connect
      current_player = Player.find_by(id: cookies[:player_id])
      reject_unauthorized_connection if current_player.blank?
    end
  end
end
