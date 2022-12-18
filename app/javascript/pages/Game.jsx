import React from 'react';
import { useParams } from 'react-router-dom';
import { useGetAreasQuery, useGetGameQuery } from '../api';
import{ formatAreasById } from '../utils';
import Map from '../components/Map';

export default function Game() {
  const { gameId } = useParams()
  const { data: game, isLoading: gameIsLoading } = useGetGameQuery(gameId);
  const { data: areas, isLoading: areasAreLoading } = useGetAreasQuery();

  if (gameIsLoading || areasAreLoading) {
    return <div>Loading</div>;
  }

  const positions = game.positions;
  const areasById = formatAreasById(areas);
  console.log(positions);

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
