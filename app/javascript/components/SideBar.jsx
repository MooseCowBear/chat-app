import React, { useRef, useEffect } from "react";
import PublicRooms from "./PublicRooms";
import consumer from "../channels/consumer";
import PrivateChats from "./PrivateChats";

export default SideBar = ({
  user,
  rooms,
  setRooms,
  currentRoom,
  setCurrentRoom,
  privateChats,
  setPrivateChats,
  setViewPeople,
}) => {
  const roomsChannel = useRef(null);
  const userChannel = useRef(null);

  const viewPeopleClickHandler = () => {
    setCurrentRoom(null);
    setViewPeople(true);
  };

  const viewWelcomeClickHandler = () => {
    setCurrentRoom(null);
    setViewPeople(false);
  };

  useEffect(() => {
    if (user) {
      roomsChannel.current = consumer.subscriptions.create(
        { channel: "RoomsChannel" },
        {
          received(data) {
            const newRooms = rooms.map((a) => {
              return { ...a };
            });
            newRooms.push(data);
            setRooms(newRooms);
          },
        }
      );

      userChannel.current = consumer.subscriptions.create(
        {
          channel: "UsersChannel",
          user_id: user.id,
        },
        {
          received(data) {
            const newChats = privateChats.map((a) => {
              return { ...a };
            });
            newChats.push(data);
            setPrivateChats(newChats);
          },
        }
      );
    }

    return () => {
      if (roomsChannel.current) {
        consumer.subscriptions.remove(roomsChannel.current);
        roomsChannel.current = null;
      }
      if (userChannel) {
        consumer.subscriptions.remove(userChannel.current);
        userChannel.current = null;
      }
    };
  }, [user, rooms]);

  // TODO: add visible state to Publicrooms and also the private chats so they are collapsable.
  // TODO: add profile...
  return (
    <div className="row-start-2 md:row-start-1 md:col-start-1 bg-gray-200 border-r-2 p-5 flex flex-col justify-between gap-5">
      <div>
        <h2 className="text-lg px-3 font-semibold flex gap-3 items-center">
          <svg
            className="h-[30px] w-[30px]"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
          >
            <path
              fill="#e879f9"
              d="M12 5.69L17 10.19V18H15V12H9V18H7V10.19L12 5.69M12 3L2 12H5V20H11V14H13V20H19V12H22"
            />
          </svg>
          <button
            onClick={viewWelcomeClickHandler}
            className="lowercase tracking-wide"
          >
            Home
          </button>
        </h2>
        <h2 className="text-lg px-3 font-semibold flex gap-3 items-center">
          <svg
            className="h-[30px] w-[30px]"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
          >
            <path
              fill="#e879f9"
              d="M15.5,12C18,12 20,14 20,16.5C20,17.38 19.75,18.21 19.31,18.9L22.39,22L21,23.39L17.88,20.32C17.19,20.75 16.37,21 15.5,21C13,21 11,19 11,16.5C11,14 13,12 15.5,12M15.5,14A2.5,2.5 0 0,0 13,16.5A2.5,2.5 0 0,0 15.5,19A2.5,2.5 0 0,0 18,16.5A2.5,2.5 0 0,0 15.5,14M10,4A4,4 0 0,1 14,8C14,8.91 13.69,9.75 13.18,10.43C12.32,10.75 11.55,11.26 10.91,11.9L10,12A4,4 0 0,1 6,8A4,4 0 0,1 10,4M2,20V18C2,15.88 5.31,14.14 9.5,14C9.18,14.78 9,15.62 9,16.5C9,17.79 9.38,19 10,20H2Z"
            />
          </svg>
          <button
            onClick={viewPeopleClickHandler}
            className="lowercase tracking-wide"
          >
            People
          </button>
        </h2>
      </div>
      <div className="flex flex-col gap-3">
        <h2 className="text-lg px-3 font-semibold flex gap-3 items-center tracking-wide">
          <svg
            className="h-[30px] w-[30px]"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
          >
            <path
              fill="#e879f9"
              d="M12,5.5A3.5,3.5 0 0,1 15.5,9A3.5,3.5 0 0,1 12,12.5A3.5,3.5 0 0,1 8.5,9A3.5,3.5 0 0,1 12,5.5M5,8C5.56,8 6.08,8.15 6.53,8.42C6.38,9.85 6.8,11.27 7.66,12.38C7.16,13.34 6.16,14 5,14A3,3 0 0,1 2,11A3,3 0 0,1 5,8M19,8A3,3 0 0,1 22,11A3,3 0 0,1 19,14C17.84,14 16.84,13.34 16.34,12.38C17.2,11.27 17.62,9.85 17.47,8.42C17.92,8.15 18.44,8 19,8M5.5,18.25C5.5,16.18 8.41,14.5 12,14.5C15.59,14.5 18.5,16.18 18.5,18.25V20H5.5V18.25M0,20V18.5C0,17.11 1.89,15.94 4.45,15.6C3.86,16.28 3.5,17.22 3.5,18.25V20H0M24,20H20.5V18.25C20.5,17.22 20.14,16.28 19.55,15.6C22.11,15.94 24,17.11 24,18.5V20Z"
            />
          </svg>
          ChatRooms
        </h2>

        <PublicRooms
          user={user}
          rooms={rooms}
          currentRoom={currentRoom}
          setCurrentRoom={setCurrentRoom}
          setViewPeople={setViewPeople}
        />
        <h2 className="text-lg px-3 font-semibold flex gap-3 items-center tracking-wide">
          <svg
            className="h-[30px] w-[30px]"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
          >
            <path
              fill="#e879f9"
              d="M12,17A2,2 0 0,0 14,15C14,13.89 13.1,13 12,13A2,2 0 0,0 10,15A2,2 0 0,0 12,17M18,8A2,2 0 0,1 20,10V20A2,2 0 0,1 18,22H6A2,2 0 0,1 4,20V10C4,8.89 4.9,8 6,8H7V6A5,5 0 0,1 12,1A5,5 0 0,1 17,6V8H18M12,3A3,3 0 0,0 9,6V8H15V6A3,3 0 0,0 12,3Z"
            />
          </svg>
          PrivateChat
        </h2>
        <PrivateChats
          user={user}
          privateChats={privateChats}
          currentRoom={currentRoom}
          setCurrentRoom={setCurrentRoom}
          setViewPeople={setViewPeople}
        />
      </div>
      <h2 className="text-lg px-3 font-semibold flex gap-3 items-center tracking-wide">
        <svg
          className="h-[30px] w-[30px]"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
        >
          <path
            fill="#e879f9"
            d="M12,19.2C9.5,19.2 7.29,17.92 6,16C6.03,14 10,12.9 12,12.9C14,12.9 17.97,14 18,16C16.71,17.92 14.5,19.2 12,19.2M12,5A3,3 0 0,1 15,8A3,3 0 0,1 12,11A3,3 0 0,1 9,8A3,3 0 0,1 12,5M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12C22,6.47 17.5,2 12,2Z"
          />
        </svg>
        profile
      </h2>
    </div>
  );
};
