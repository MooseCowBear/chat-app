require 'rails_helper'

RSpec.describe Room, type: :model do
  before(:each) do
    @room1 = create(:room)
  end

  it "is valid with valid attributes" do
    expect(@room1).to be_valid
  end

  it "has a name" do
    room2 = build(:room, name: "")
    expect(room2).not_to be_valid
  end

  it "has a unigue name" do
    room2 = build(:room)
    expect(room2).not_to be_valid
  end

  it "has a name 45 characters or less" do
    room2 = build(:room, name: "a" * 46)
    expect(room2).not_to be_valid
  end

  it "strips white space from name" do 
    room2 = create(:room, name: "   test   ");
    expect(room2.name).to eq("test")
  end

  it "lowercases name" do
    room2 = create(:room, name: "TEST");
    expect(room2.name).to eq("test")
  end

  describe ".public_rooms" do
    before(:each) do 
      @room2 = create(:room, name: "private room", is_private: true)
    end

    it "includes public rooms" do
      expect(Room.public_rooms).to include(@room1)
    end

    it "excludes private rooms" do
      expect(Room.public_rooms).not_to include(@room2)
    end
  end

  describe ".user_private_rooms" do
    before(:each) do
      @user1 = create(:user)
    end

    it "includes rooms where user is interlocutor one and not marked_delete_one" do
      room2 = create(:room, name: "room", interlocutor_one: @user1)
      expect(Room.user_private_rooms(@user1)).to include(room2)
    end

    it "excludes rooms where user is interlocutor one and marked_delete_one" do
      room2 = create(:room, name: "room", interlocutor_one: @user1, marked_delete_one: true)
      expect(Room.user_private_rooms(@user1)).not_to include(room2)
    end

    it "excludes rooms where user is not interlocutor one or interlocutor two" do
      expect(Room.user_private_rooms(@user1)).not_to include(@room1)
    end

    it "includes rooms where user is interlocutor two and not marked_delete_two" do
      room2 = create(:room, name: "room", interlocutor_two: @user1)
      expect(Room.user_private_rooms(@user1)).to include(room2)
    end

    it "excludes rooms where user is interlocutor two and marked_delete_two" do
      room2 = create(:room, name: "room", interlocutor_two: @user1, marked_delete_two: true)
      expect(Room.user_private_rooms(@user1)).not_to include(room2)
    end
  end

  describe ".active" do
    it "includes rooms where creator is nil and last updated over a week ago" do
      room2 = create(:old_room)
      expect(Room.active).to include(room2)
    end

    it "includes rooms updated in last week" do
      user1 = create(:user, email: "frank@test.com", username: "frank")
      room2 = create(:new_room, creator: user1)
      expect(Room.active).to include(room2)
    end

    it "excludes rooms with creator that were last updated more than a week ago" do
      user1 = create(:user, email: "frank@test.com", username: "frank")
      room2 = create(:old_room, creator: user1)
      expect(Room.active).not_to include(room2)
    end
  end

  describe ".private_destroyable" do
    before(:each) do
      @user1 = create(:user)
    end

    it "includes rooms where user is interlocutor one and interlocutor two is nil" do
      room2 = create(:room, name: "room", interlocutor_one: @user1)
      expect(Room.private_destroyable(@user1)).to include(room2)
    end

    it "includes rooms where user is interlocutor two and interlocutor one is nil" do
      room2 = create(:room, name: "room", interlocutor_two: @user1)
      expect(Room.private_destroyable(@user1)).to include(room2)
    end

    it "excludes rooms where user is not interlocutor one or two" do
      expect(Room.private_destroyable(@user1)).not_to include(@room1)
    end

    it "excludes rooms where user is interlocutor one and interlocutor two is not nil" do 
      user2 = create(:user, email: "frank@test.com", username: "frank")
      room2 = create(:room, name: "room", interlocutor_one: @user1, interlocutor_two: user2)
      expect(Room.private_destroyable(@user1)).not_to include(room2)
    end

    it "excludes rooms where user is interlocutor two and interloutor one is not nil" do
      user2 = create(:user, email: "frank@test.com", username: "frank")
      room2 = create(:room, name: "room", interlocutor_one: user2, interlocutor_two: @user1)
      expect(Room.private_destroyable(@user1)).not_to include(room2)
    end
  end

  describe "#interlocutor_one?" do
    before(:each) do
      @user1 = create(:user)
    end

    it "returns true when user is interlocutor one" do
      room2 = create(:room, name: "room", interlocutor_one: @user1)
      expect(room2.interlocutor_one?(@user1)).to be
    end

    it "return false when user is not interlocutor one" do
      expect(@room1.interlocutor_one?(@user1)).not_to be
    end
  end

  describe "#interlocutor_two?" do
    before(:each) do
      @user1 = create(:user)
    end

    it "returns true when user is interlocutor two" do
      room2 = create(:room, name: "room", interlocutor_two: @user1)
      expect(room2.interlocutor_two?(@user1)).to be
    end

    it "return false when user is not interlocutor two" do
      expect(@room1.interlocutor_two?(@user1)).not_to be
    end
  end

  describe "#participant?" do
    before(:each) do
      @user1 = create(:user)
    end

    it "returns true if user is interlocutor one and room is private" do
      room2 = create(:room, name: "room", is_private: true, interlocutor_one: @user1)
      expect(room2.participant?(@user1)).to be
    end

    it "returns true if user is interlocutor two and room is private" do
      room2 = create(:room, name: "room", is_private: true, interlocutor_two: @user1)
      expect(room2.participant?(@user1)).to be
    end

    it "returns false if user is not interlocutor one or two and room is private" do
      room2 = create(:room, name: "room", is_private: true)
      expect(room2.participant?(@user1)).not_to be
    end

    it "returns true if room is public" do
      expect(@room1.participant?(@user1)).to be
    end
  end

  describe "#room_messages" do
    before(:each) do
      @user1 = create(:user)
    end

    it "returns all messages for a public room" do
      message = create(:message, room: @room1, user: @user1)
      expect(@room1.room_messages(@user1)).to include(message)
    end

    it "includes messages created after restored_at_one if user is interlocutor one and restored_at_one" do
      private_room = create(:room, name: "private room", interlocutor_one: @user1, restored_at_one: 1.day.ago)
      message = create(:message, room: private_room, user: @user1)
      expect(private_room.room_messages(@user1)).to include(message)
    end

    it "includes messages created after restored_at_two if user is interlocutor two and restored_at_two" do
      private_room = create(:room, name: "private room", interlocutor_two: @user1, restored_at_two: 1.day.ago)
      message = create(:message, room: private_room, user: @user1)
      expect(private_room.room_messages(@user1)).to include(message)
    end

    it "excludes messages created before restored_at_one if user is interlocutor one and restored_at_one" do
      private_room = create(:room, name: "private room", interlocutor_one: @user1, restored_at_one: 1.day.ago)
      message = create(:old_message, room: private_room, user: @user1)
      expect(private_room.room_messages(@user1)).not_to include(message)
    end

    it "excludes messages created before restored_at_two if user is interlocutor two and restored_at_two" do
      private_room = create(:room, name: "private room", interlocutor_two: @user1, restored_at_two: 1.day.ago)
      message = create(:old_message, room: private_room, user: @user1)
      expect(private_room.room_messages(@user1)).not_to include(message)
    end
  end

  describe "#restoring_for_one?" do
    before(:each) do
      @user1 = create(:user)
    end

    it "returns true if user is interlocutor one and marked_delete_one" do
      room2 = create(:room, name: "room", interlocutor_one: @user1, marked_delete_one: true)
      expect(room2.restoring_for_one?(@user1)).to be
    end

    it "returns false if not marked_delete_one" do
      room2 = create(:room, name: "room", interlocutor_one: @user1)
      expect(room2.restoring_for_one?(@user1)).not_to be
    end

    it "returns false if user if not interlocutor one" do 
      room2 = create(:room, name: "room", marked_delete_one: true)
      expect(room2.restoring_for_one?(@user1)).not_to be
    end
  end

  describe "#restoring_for_two?" do
    before(:each) do
      @user1 = create(:user)
    end

    it "returns true if user is interlocutor two and marked_delete_two" do
      room2 = create(:room, name: "room", interlocutor_two: @user1, marked_delete_two: true)
      expect(room2.restoring_for_two?(@user1)).to be
    end

    it "returns false if not marked_delete_two" do
      room2 = create(:room, name: "room", interlocutor_two: @user1)
      expect(room2.restoring_for_two?(@user1)).not_to be
    end

    it "returns false if user if not interlocutor two" do 
      room2 = create(:room, name: "room", marked_delete_two: true)
      expect(room2.restoring_for_two?(@user1)).not_to be
    end
  end

  describe "#private_room_destroy" do
    before(:each) do
      @user1 = create(:user)
    end

    it "destroys room if either interlocutor is nil" do
      allow(:room).to receive(:missing_interlocutor?).and_return true
      room2 = create(:room, name: "room", is_private: true, interlocutor_one: @user1)
      room2.private_room_destroy(@user1)
      expect { room2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "destroys room if user is interlocutor one and marked_delete_two" do
      room2 = create(:room, name: "room", is_private: true, interlocutor_one: @user1, marked_delete_two: true)
      room2.private_room_destroy(@user1)
      expect { room2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "destroys room if user is interlocutor two and marked_delete_one" do
      room2 = create(:room, name: "room", is_private: true, interlocutor_two: @user1, marked_delete_one: true)
      room2.private_room_destroy(@user1)
      expect { room2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "sets marked_delete_one true, restored_at_one to nil if user is interlocutor one and not marked_delete_two" do
      user2 = create(:user, username: "frank", email: "frank@test.com")
      room2 = create(:room, name: "room", is_private: true, interlocutor_one: @user1, interlocutor_two: user2, restored_at_one: 2.days.ago)

      expect { room2.private_room_destroy(@user1) }
        .to change(room2, :marked_delete_one).from(false).to(true)
        .and change(room2, :restored_at_one).to(nil)
    end

    it "sets marked_delete_two true, restored_at_two to nil if user is interlocutor two and not marked_delete_one" do
      user2 = create(:user, username: "frank", email: "frank@test.com")
      room2 = create(:room, name: "room", is_private: true, interlocutor_two: @user1, interlocutor_one: user2, restored_at_two: 2.days.ago)

      expect { room2.private_room_destroy(@user1) }
        .to change(room2, :marked_delete_two).from(false).to(true)
        .and change(room2, :restored_at_two).to(nil)
    end
  end
end
