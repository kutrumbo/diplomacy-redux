import React, { useLayoutEffect, useRef, useState } from 'react';
import classNames from 'classnames';
import Unit, { UNIT_SIZES } from './Unit';
import mapSrc from '../images/map.jpg';
import { fixAssetSrc } from '../utils';

const calcUnitSize = (width) => {
  if (width < 1000) {
    return UNIT_SIZES.SMALL;
  } else {
    return UNIT_SIZES.MEDIUM;
  }
};

export default function Map({ areasById, className = '', positions }) {
  const ref = useRef(null);
  const [width, setWidth] = useState(0);
  const getWidth = () => ref.current.offsetWidth;

  useLayoutEffect(() => {
    const handleResize = () => {
      setWidth(getWidth());
    };

    if (ref.current) {
      setWidth(getWidth());
    }

    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
    }
  }, [ref]);

  const clazz = classNames(className, "w-full relative");

  return (
    <div className={clazz} ref={ref} >
      <img className="object-cover" src={fixAssetSrc(mapSrc)} />
      {positions.map(position => <Unit key={position.id} areasById={areasById} size={calcUnitSize(width)} {...position} />)}
    </div>
  );
}