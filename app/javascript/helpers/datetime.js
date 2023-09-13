const isToday = (dateString) => {
  const inputDate = new Date(dateString);
  const today = new Date();
  return inputDate.setHours(0, 0, 0, 0) == today.setHours(0, 0, 0, 0);
};

const displayTime = (dateString) => {
  const inputDate = new Date(dateString);
  const hours = inputDate.getHours();
  const minutes = inputDate.getMinutes();

  return `${hours % 12}:${minutes.toString().padStart(2, "0")} ${
    hours >= 12 ? "pm" : "am"
  }`;
};

const displayDate = (dateString) => {
  const inputDate = new Date(dateString);
  const month = inputDate.getMonth();
  const day = inputDate.getDay();
  const year = inputDate.getFullYear();

  return `${month}/${day}/${year}`;
};

export const displayDateTime = (dateString) => {
  if (isToday(dateString)) {
    return displayTime(dateString);
  }
  return displayDate(dateString);
};
