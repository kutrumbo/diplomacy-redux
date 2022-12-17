import React from 'react';
import classNames from 'classnames';

export default function Badge({ danger, neutral, success, text }) {
  const clazz = classNames(
    'px-3 py-1 text-white text-xs rounded-full uppercase',
    {
      'bg-green-500': success,
      'bg-red-500': danger,
      'bg-stone-400': neutral,
    },
  );

  return (
    <div className={clazz}>{text}</div>
  );
}
