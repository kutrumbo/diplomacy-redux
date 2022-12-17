import React from 'react';
import classNames from 'classnames';

export default function Button({ className = '', danger, neutral, onClick, small, text }) {
  const clazz = classNames(
    'block text-white rounded shadow',
    className,
    {
      'bg-amber-500 hover:bg-amber-400 active:bg-amber-600': !danger && !neutral,
      'bg-red-500 hover:bg-red-400 active:bg-red-600': danger,
      'bg-stone-400 hover:bg-stone-300 active:bg-stone-500': neutral,
      'text-sm px-3 py-1.5': !small,
      'text-xs px-1.5 py-1': small,
    },
  );

  return (
    <button className={clazz} type="button" onClick={onClick}>{text}</button>
  );
}
