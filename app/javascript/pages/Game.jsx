import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { startCase, partial } from 'lodash';
import { useGetAreasQuery, useGetGameQuery, useUpdateOrdersMutation } from '../api';
import{ groupById } from '../utils';
import Button from '../components/Button';
import OrderInput from '../components/OrderInput';
import { LoadingIndicator } from '../components/icons';
import Map from '../components/Map';
import PreviousTurns from '../components/PreviousTurns';

export default function Game() {
  const { gameId } = useParams()
  const { data: game, isLoading: gameIsLoading } = useGetGameQuery(gameId);
  const { data: areas, isLoading: areasAreLoading } = useGetAreasQuery();
  const [orders, setOrders] = useState([]);
  const [syncOrders, { isLoading: isSubmitting }] = useUpdateOrdersMutation();

  useEffect(() => {
    console.log(game);
    if (game) {
      setOrders(game.orders);
    }
  }, [game]);

  if (gameIsLoading || areasAreLoading) {
    return <div className="flex gap-x-3">Loading {<LoadingIndicator className="w-4" />}</div>;
  }

  const { pastOrders, players, positions, turn, turns } = game;
  const playersById = groupById(players);
  const positionsById = groupById(positions);
  const areasById = groupById(areas, 'name');

  const updateOrder = (index, order) => {
    const updatedOrders = [...orders];
    updatedOrders[index] = order;
    setOrders(updatedOrders);
  };

  const submitOrders = async () => {
    const result = await syncOrders({ gameId: game.id, orders }).unwrap();
    // TODO: do we need to check result?
  }

  const allOrdersConfirmed = !orders.find(order => !order.confirmed);

  return (
    <div className="flex min-h-screen">
      <div className="w-[45%] p-8">
        <h1 className="text-xl mb-8">Game: {game.name}</h1>
        <h2 className="text-l mb-8">Turn: {startCase(game.turn.type)} {game.year}</h2>
        {orders.map((order, index) => (
          <OrderInput
            key={index}
            areas={areas}
            areasById={areasById}
            order={order}
            player={playersById[positionsById[order.positionId].playerId]}
            position={positionsById[order.positionId]}
            turn={turn}
            updateOrder={partial(updateOrder, index)}
          />
        ))}
        <div className="flex w-full justify-end my-6">
          <Button
            disabled={!allOrdersConfirmed}
            isLoading={isSubmitting}
            onClick={submitOrders}
            text="Submit Orders"
          />
        </div>
        <div>
          <h2 className="mb-8" >Previous Turns</h2>
          <PreviousTurns pastOrders={pastOrders} turns={turns} playersById={playersById} areasById={areasById} />
        </div>
      </div>
      <div className="w-[55%]">
        <Map playersById={playersById} positions={positions} areasById={areasById} />
      </div>
    </div>
  );
}
