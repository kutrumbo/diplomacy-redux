import React from 'react';
import classNames from 'classnames';

export default function Select({ className = '', children, invalid, name, onChange, value }) {
  const clazz = classNames(
    'text-xs px-1.5 py-1 rounded hover:bg-blue-100 hover:cursor-pointer appearance-none focus:ring-0',
    className,
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
