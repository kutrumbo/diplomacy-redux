import React from 'react';
import classNames from 'classnames';

export default function Button({ className = '', onClick, text }) {
  const clazz = classNames(
    "block px-3 py-1.5 bg-indigo-500 hover:bg-indigo-400 active:bg-indigo-600 text-white rounded shadow",
    className,
  );

  return (
    <button className={clazz} type="button" onClick={onClick}>{text}</button>
  );
}
