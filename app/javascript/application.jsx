import React from 'react';
import { createRoot } from 'react-dom/client';
import { ApiProvider } from '@reduxjs/toolkit/query/react';
import { api } from './api';
import Sandbox from './pages/Sandbox';

function App() {
  return (
    <ApiProvider api={api}>
      <Sandbox />
    </ApiProvider>
  );
}

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('app');
  const root = createRoot(container);
  root.render(<App />);
});
