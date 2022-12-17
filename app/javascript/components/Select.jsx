import React from 'react';
import classNames from 'classnames';

export default function Select({ children, invalid, name, onChange, value }) {
  const clazz = classNames(
    'hover:cursor-pointer focus:ring-0',
    {
      'focus:border-black': !invalid,
      'border-red-500 focus:border-red-500': invalid,
    }
  );

  return (
    <select className={clazz} name={name} value={value} onChange={onChange}>
      {children}
    </select>
  );
}
