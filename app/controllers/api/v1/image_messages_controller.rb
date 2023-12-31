class Api::V1::ImageMessagesController < ApplicationController
  include ConfirmParticipantConcern

  before_action :confirm_participant, only: [:create]
  after_action -> { current_user.update_last_active if current_user }

  def create
    message = Message.new

    res = Cloudinary::Uploader.upload(
      message_params[:image], 
      { 
        allowed_formats: ["jpeg", "jpg", "png"], 
        folder: "ChatApp", 
        upload_preset: "frcpb9q2" 
      }
    )
  
    message.image = res["secure_url"] # if doesn't exist, will be nil
    message.public_id = res["public_id"]

    message.user = current_user
    message.room = @room

    if message.save 
      render json: message.to_json(include: [:user])
    else
      render json: { message: "Validations Failed", 
                    errors: message.errors.full_messages }, 
                    status: :unprocessable_entity
    end
  end

  private

  def message_params 
    params.permit(:room_id, :image)
  end
end
