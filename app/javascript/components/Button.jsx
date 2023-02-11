import React from 'react';
import classNames from 'classnames';
import { noop } from 'lodash';
import { LoadingIndicator } from './icons';

export default function Button({ className = '', danger, disabled, isLoading, neutral, onClick, small, text }) {
  const clazz = classNames(
    'block text-white rounded shadow',
    className,
    {
      'bg-amber-500 hover:bg-amber-400 active:bg-amber-600': !danger && !neutral && !disabled,
      'bg-red-500 hover:bg-red-400 active:bg-red-600': danger && !disabled,
      'bg-stone-400 hover:bg-stone-300 active:bg-stone-500': neutral && !disabled,
      'text-sm px-3 py-1.5': !small,
      'text-xs px-1.5 py-1': small,
      'bg-gray-300 cursor-not-allowed': disabled,
    },
  );

  return (
    <button className={clazz} type="button" disabled={disabled || isLoading} onClick={isLoading ? noop : onClick}>
      {isLoading ? (
        <>
          {text}
          <LoadingIndicator className={`inline ml-2 ${small ? 'h-3' : 'h-4'}`} />
        </>
      ) : text}
    </button>
  );
}
