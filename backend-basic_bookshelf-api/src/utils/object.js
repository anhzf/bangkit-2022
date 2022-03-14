export const pick = (obj, keys) => {
  const copy = Object.assign(Object.create(obj), obj);

  Object.keys(obj).forEach((key) => {
    if (!keys.includes(key)) delete copy[key];
  });

  return copy;
};
