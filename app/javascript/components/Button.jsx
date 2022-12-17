import React from 'react';
import classNames from 'classnames';

export default function Button({ className = '', danger, neutral, onClick, text }) {
  const clazz = classNames(
    "block px-3 py-1.5 text-white rounded shadow",
    className,
    {
      "bg-indigo-500 hover:bg-indigo-400 active:bg-indigo-600": !danger && !neutral,
      "bg-red-500 hover:bg-red-400 active:bg-red-600": danger,
      "bg-stone-400 hover:bg-stone-300 active:bg-stone-500": neutral,
    },
  );

  return (
    <button className={clazz} type="button" onClick={onClick}>{text}</button>
  );
}
