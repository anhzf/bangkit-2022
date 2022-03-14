const debugValue = {};

export const setDebugValue = (label, value) => {
  debugValue[label] = value;
};

export const getDebugValue = () => debugValue;

export const hasDebugValue = () => Object.keys(debugValue).length > 0;

export const shouldDebug = () => (process.env.DEBUG === undefined
  ? process.env.NODE_ENV === 'development'
  : process.env.DEBUG && hasDebugValue());

export const clearDebugValue = () => {
  Object.keys(debugValue).forEach((key) => {
    delete debugValue[key];
  });
};
