import React from 'react';

export default function Checkbox({ checked, disabled, name, onChange }) {

  return (
    <input
      type="checkbox"
      name={name}
      checked={checked}
      className="text-blue-500 disabled:bg-gray-200 disabled:cursor-not-allowed focus:ring-0 rounded-sm"
      disabled={disabled}
      onChange={onChange}
    />
  );
}
