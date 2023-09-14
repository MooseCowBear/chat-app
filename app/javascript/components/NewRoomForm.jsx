import React, { useState } from "react";

export default NewRoomForm = () => {
  const [name, setName] = useState("");
  const [inputError, setInputError] = useState(null);
  const [validationError, setValidationError] = useState([]);

  const errorMessage = inputError
    ? "Room must have a name."
    : validationError
    ? `${validationError.join(", ")}`
    : "";

  const changeHandler = (e) => {
    const input = e.target.value;
    setName(input);
  };

  const resetForm = () => {
    setName("");
    setInputError(null);
    setValidationError(null);
  };

  const submitHandler = (e) => {
    e.preventDefault();
    console.log("new room form submitted");
    const input = document.getElementById("name").value;
    if (input.trim() === "") {
      setInputError(true);
      return;
    }

    const createRoom = async () => {
      const url = "/api/v1/rooms/create";
      const token = document.querySelector('meta[name="csrf-token"]').content;
      const body = { name };

      try {
        const response = await fetch(url, {
          method: "POST",
          headers: {
            "X-CSRF-Token": token,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(body),
        });

        // is this what we want?
        if (response.status !== 200 && response.status !== 422) {
          resetForm();
          throw new Error("A network error occured.");
        }

        const parsedResponse = await response.json();
        console.log(parsedResponse);

        if (parsedResponse.hasOwnProperty("errors")) {
          setValidationError(parsedResponse.errors);
        } else {
          resetForm();
        }
      } catch (error) {
        console.log(error);
        setValidationError(["Request could not be completed"]);
      }
    };
    createRoom();
  };

  return (
    <form onSubmit={submitHandler} className="bg-gray-50 rounded-md p-3 w-fit">
      <h2 className="font-semibold uppercase tracking-wider leading-tight">
        New room
      </h2>
      <div className="flex items-center gap-2">
        <label className="flex flex-col lowercase">
          <span className="text-pink-600">{errorMessage}</span>
          <input
            id="name"
            type="text"
            value={name}
            onChange={changeHandler}
            className="px-3 py-1 border-2 border-gray-200 rounded-lg max-w-[200px] max-h-[50px] text-sm"
          />
        </label>
        <button type="submit" aria-label="create room">
          <svg
            className="h-[30px]"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
          >
            <path
              fill="#e879f9"
              d="M19,13H13V19H11V13H5V11H11V5H13V11H19V13Z"
            />
          </svg>
        </button>
      </div>
    </form>
  );
};