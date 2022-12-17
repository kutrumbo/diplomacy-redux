import React from 'react';
import { createRoot } from 'react-dom/client';
import Sandbox from './components/Sandbox';

function App() {
  return (
    <Sandbox />
  );
}

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('app');
  const root = createRoot(container);
  root.render(<App />);
});
