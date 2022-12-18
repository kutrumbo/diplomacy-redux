import React from 'react';
import { createRoot } from 'react-dom/client';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { ApiProvider } from '@reduxjs/toolkit/query/react';
import { api } from './api';
import Game from './pages/Game';
import Home from './pages/Home';
import Sandbox from './pages/Sandbox';

const router = createBrowserRouter([
  {
    path: '/',
    element: <Home />,
  },
  {
    path: '/sandbox',
    element: <Sandbox />,
  },
  {
    path: '/games/:id',
    element: <Game />,
  }
]);

function App() {
  return (
    <ApiProvider api={api}>
      <RouterProvider router={router} />
    </ApiProvider>
  );
}

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('app');
  const root = createRoot(container);
  root.render(<App />);
});
