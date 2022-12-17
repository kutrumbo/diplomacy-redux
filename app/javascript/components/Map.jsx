import React from 'react';
import classNames from 'classnames';
import Unit from './Unit';
import mapSrc from '../images/map.jpg';
import { fixAssetSrc } from '../utils';

export default function Map({ areasById, className = '', positions }) {
  const clazz = classNames(className, "relative w-full h-full");
  return (
    <div className={clazz}>
      <img className="w-full" src={fixAssetSrc(mapSrc)} />
      {positions.map(position => <Unit key={position.id} areasById={areasById} {...position} />)}
    </div>
  );
}
