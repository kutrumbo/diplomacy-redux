import React from 'react';
import classNames from 'classnames';
import { NATIONALITY_COLORS, UNIT_TYPES } from '../const';
import { areaPositionClassName } from '../utils';

export const UNIT_SIZES = {
  SMALL: 'small',
  MEDIUM: 'medium',
};

function Army({ className }) {
  return (
    <svg className={className} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
      <path d="M 9 6 C 7.895 6 7 6.895 7 8 L 7 10 L 16 10 L 15.5 9 L 21 9 L 21 7 L 14.46875 7 C 14.11175 6.389 13.464 6 12.75 6 L 9 6 z M 5 11 C 4 11 2.59375 12.59375 2.59375 12.59375 C 1.98475 13.20375 1.83275 14.13525 2.21875 14.90625 L 4.625 17.875 C 5.198 18.592 6.083 19 7 19 L 17 19 C 17.917 19 18.83425 18.593 19.40625 17.875 L 21.8125 14.90625 C 22.1985 14.13525 22.0465 13.20275 21.4375 12.59375 C 21.4375 12.59375 20 11 19 11 L 5 11 z M 4.03125 14 L 7 14 L 10 14 L 14 14 L 17 14 L 20 14 L 17.84375 16.625 C 17.65175 16.864 17.306 17 17 17 L 7 17 C 6.694 17 6.3785 16.864 6.1875 16.625 L 4.03125 14 z M 17 14 C 16.447716 14 16 14.447715 16 15 C 16 15.552285 16.447716 16 17 16 C 17.552285 16 18 15.552285 18 15 C 18 14.447715 17.552285 14 17 14 z M 14 14 C 13.447715 14 13 14.447715 13 15 C 13 15.552285 13.447715 16 14 16 C 14.552284 16 15 15.552285 15 15 C 15 14.447715 14.552284 14 14 14 z M 10 14 C 9.4477148 14 9 14.447715 9 15 C 9 15.552285 9.4477148 16 10 16 C 10.552284 16 11 15.552285 11 15 C 11 14.447715 10.552284 14 10 14 z M 7 14 C 6.4477153 14 6 14.447715 6 15 C 6 15.552285 6.4477153 16 7 16 C 7.5522848 16 8 15.552285 8 15 C 8 14.447715 7.5522848 14 7 14 z"/>
    </svg>
  );
};

function Fleet({ className }) {
  return (
    <svg className={className} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
      <path d="M 11 3 L 11 6 L 10 6 C 9.448 6 9 6.448 9 7 L 9 8 L 7 8 C 6.448 8 6 8.448 6 9 L 4 9 L 4 11 L 6 11 L 6 12 L 10 12 L 15 12 L 17 12 L 17 11.6875 L 20.40625 11 L 20 9.03125 L 16.90625 9.65625 C 16.761432 9.2823601 16.424824 9 16 9 L 15 9 L 15 7 C 15 6.448 14.552 6 14 6 L 13 6 L 13 3 L 11 3 z M 2 13 L 3.6875 18.875 C 3.9825 18.943 4.263 19 4.5 19 C 5.194 19 6.261 18.754 7 18 C 7.739 18.754 8.806 19 9.5 19 C 10.194 19 11.261 18.754 12 18 C 12.739 18.754 13.806 19 14.5 19 C 15.194 19 16.261 18.754 17 18 C 17.739 18.754 18.806 19 19.5 19 C 19.737 19 20.0175 18.943 20.3125 18.875 L 22 13 L 2 13 z M 17 15 L 20 15 L 20 16 L 17 16 L 17 15 z M 2 19 L 2 21 C 2.739 21.754 3.806 22 4.5 22 C 5.194 22 6.261 21.754 7 21 C 7.739 21.754 8.806 22 9.5 22 C 10.194 22 11.261 21.754 12 21 C 12.739 21.754 13.806 22 14.5 22 C 15.194 22 16.261 21.754 17 21 C 17.739 21.754 18.806 22 19.5 22 C 20.194 22 21.261 21.754 22 21 L 22 19 C 21.261 19.754 20.194 20 19.5 20 C 18.806 20 17.739 19.754 17 19 C 16.261 19.754 15.194 20 14.5 20 C 13.806 20 12.739 19.754 12 19 C 11.261 19.754 10.194 20 9.5 20 C 8.806 20 7.739 19.754 7 19 C 6.261 19.754 5.194 20 4.5 20 C 3.806 20 2.739 19.754 2 19 z"/>
    </svg>
  );
};

function Unitless({ className }) {
  return (
    <svg className={className} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
      <circle cx="50" cy="50" r="25" />
    </svg>
  );
};

export default function PositionMarker({ areasById={areasById}, player, position, size }) {
  const clazz = classNames(
    areaPositionClassName(areasById[position.areaId]),
    NATIONALITY_COLORS[player.nationality],
    'absolute drop-shadow-lg',
    {
      'w-8 h-8': size === UNIT_SIZES.SMALL,
      'w-10 h-10': size !== UNIT_SIZES.SMALL,
    },
  );

  if (position.unitType === UNIT_TYPES.ARMY) {
    return (<Army className={clazz} />);
  } else if (position.unitType === UNIT_TYPES.FLEET) {
    return (<Fleet className={clazz} />);
  } else {
    return (<Unitless className={clazz} />);
  }
}
