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

// necessary because esbuild is not properly pre-pending asset src strings with /assets
export const fixAssetSrc = (srcString) => srcString.replace('./', '/assets/');

export const formatAreasById = (areas) => {
  return areas.reduce((obj, area) => {
    obj[area.id] = area.name;
    return obj;
  }, {});
}

export const groupById = (arr, valueField = null) => {
  return arr.reduce((result, obj) => {
    result[obj.id] = valueField ? obj[valueField] : obj;
    return result;
  }, {});
};

const AREA_COORDS = {
  adriatic_sea: 'top-[76%] left-[50%]',
  aegean_sea: 'top-[91%] left-[67%]',
  albania: 'top-[81%] left-[56.5%]',
  ankara: 'top-[80%] left-[82%]',
  apulia: 'top-[80%] left-[50%]',
  armenia: 'top-[78%] left-[93%]',
  baltic_sea: 'top-[41.5%] left-[54%]',
  barents_sea: 'top-[3%] left-[73%]',
  belgium: 'top-[53%] left-[34.7%]',
  berlin: 'top-[50%] left-[47.5%]',
  black_sea: 'top-[72%] left-[80%]',
  bohemia: 'top-[57%] left-[49%]',
  brest: 'top-[58%] left-[25.5%]',
  budapest: 'top-[63%] left-[59%]',
  bulgaria_east: 'top-[75%] left-[69%]',
  bulgaria_south: 'top-[80%] left-[66%]',
  bulgaria: 'top-[77%] left-[65%]',
  burgundy: 'top-[61%] left-[34%]',
  clyde: 'top-[33%] left-[25%]',
  constantinople: 'top-[82%] left-[72%]',
  denmark: 'top-[40%] left-[44%]',
  eastern_mediterranean: 'top-[95%] left-[75%]',
  edinburgh: 'top-[34%] left-[29%]',
  english_channel: 'top-[51%] left-[25%]',
  finland: 'top-[25%] left-[62%]',
  galicia: 'top-[58%] left-[62%]',
  gascony: 'top-[66%] left-[26%]',
  greece: 'top-[88%] left-[61%]',
  gulf_of_bothnia: 'top-[32%] left-[57%]',
  gulf_of_lyons: 'top-[76%] left-[33%]',
  heligoland_bight: 'top-[43%] left-[39%]',
  holland: 'top-[49%] left-[37%]',
  ionian_sea: 'top-[90%] left-[54%]',
  irish_sea: 'top-[46%] left-[19%]',
  kiel: 'top-[51%] left-[42.5%]',
  liverpool: 'top-[41%] left-[27%]',
  livonia: 'top-[43%] left-[63%]',
  london: 'top-[48%] left-[30%]',
  marseilles: 'top-[70%] left-[32.5%]',
  mid_atlantic_ocean: 'to]%[-left-[, 5%]',
  moscow: 'top-[43%] left-[73%]',
  munich: 'top-[58%] left-[42%]',
  naples: 'top-[86%] left-[50%]',
  north_africa: 'top-[92%] left-[20%]',
  north_atlantic_ocean: 'top-[27%] left-[14%]',
  north_sea: 'top-[34%] left-[36%]',
  norway: 'top-[24%] left-[46%]',
  norwegian_sea: 'top-[16%] left-[38%]',
  paris: 'top-[59%] left-[29%]',
  picardy: 'top-[54%] left-[30%]',
  piedmont: 'top-[69%] left-[39%]',
  portugal: 'to]%[-left-[, 9%]',
  prussia: 'top-[47%] left-[53%]',
  rome: 'top-[78%] left-[45%]',
  ruhr: 'top-[54%] left-[39%]',
  rumania: 'top-[70%] left-[68%]',
  saint_petersburg_north: 'top-[14%] left-[73%]',
  saint_petersburg_south: 'top-[31%] left-[65%]',
  saint_petersburg: 'top-[25%] left-[72%]',
  serbia: 'top-[76%] left-[59%]',
  sevastopol: 'top-[58%] left-[79%]',
  silesia: 'top-[53%] left-[51%]',
  skagerrack: 'top-[34%] left-[45%]',
  smyrna: 'top-[88%] left-[75%]',
  spain_north: 'top-[67%] left-[17%]',
  spain_south: 'top-[83%] left-[18%]',
  spain: 'top-[76%] left-[16%]',
  sweden: 'top-[26%] left-[51%]',
  syria: 'top-[92%] left-[90%]',
  trieste: 'top-[71%] left-[52%]',
  tunis: 'top-[94%] left-[38%]',
  tuscany: 'top-[74%] left-[42%]',
  tyrolia: 'top-[64%] left-[45%]',
  tyrrhenian_sea: 'top-[84%] left-[43%]',
  ukraine: 'top-[57%] left-[70%]',
  venice: 'top-[70%] left-[43%]',
  vienna: 'top-[62%] left-[52%]',
  wales: 'top-[47%] left-[25%]',
  warsaw: 'top-[52%] left-[59%]',
  western_mediterranean: 'top-[85%] left-[27%]',
  yorkshire: 'top-[42%] left-[30%]',
};

export const areaPositionClassName = (area) => AREA_COORDS[snakeCase(area)];

export const turnYear = turn => 1901 + Math.floor(turn.number / 5);
