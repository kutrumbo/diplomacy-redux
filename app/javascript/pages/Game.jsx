import React from 'react';
import { useParams } from 'react-router-dom';
import { useGetGameQuery } from '../api';
import Map from '../components/Map';

export default function Game() {
  const { gameId } = useParams()
  const { data: game, isLoading } = useGetGameQuery(gameId);
  const positions = [];
  const areasById = {};

  if (isLoading) {
    return <div>Loading</div>;
  }

  return (
    <div className="flex min-h-screen">
      <div className="w-[45%] p-8">
        <h1 className="text-xl mb-8">{game.name}</h1>
      </div>
      <div className="w-[55%]">
        <Map positions={positions} areasById={areasById} />
      </div>
    </div>
  );
}
