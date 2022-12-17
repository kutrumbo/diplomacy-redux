import { camelCase, isArray, isPlainObject, snakeCase } from 'lodash';

export const deepMapKeys = (input, iteratee, excludeKeys = []) => {
  if (isArray(input)) {
    return input.map(v => deepMapKeys(v, iteratee, excludeKeys));
  }

  if (!isPlainObject(input)) return input;
  const result = {};

  Object.keys(input).forEach(key => {
    let value = input[key];
    const mappedKey = iteratee(key, value);

    if (!excludeKeys?.includes(mappedKey) && (isPlainObject(value) || isArray(value))) {
      value = deepMapKeys(value, iteratee, excludeKeys);
    }
    result[mappedKey] = value;
  });

  return result;
};

export const camelCaseKeys = (input, excludeKeys = []) => deepMapKeys(input, key => camelCase(key), excludeKeys);
export const snakeCaseKeys = (input, excludeKeys = []) => deepMapKeys(input, key => snakeCase(key), excludeKeys);
