class ChatChannel < ApplicationCable::Channel
  # testing for notifications...

  def subscribed
    stream_from "chat_#{params[:room_id]}"
    current_user.update(current_room_id: params[:room_id])
  end

  def unsubscribed
    current_user.update(current_room_id: nil)
    # Any cleanup needed when channel is unsubscribed
  end
end
