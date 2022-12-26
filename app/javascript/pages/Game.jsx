import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { partial } from 'lodash';
import { useGetAreasQuery, useGetGameQuery, useUpdateOrdersMutation } from '../api';
import{ groupById } from '../utils';
import Button from '../components/Button';
import OrderInput from '../components/OrderInput';
import Map from '../components/Map';

export default function Game() {
  const { gameId } = useParams()
  const { data: game, isLoading: gameIsLoading } = useGetGameQuery(gameId);
  const { data: areas, isLoading: areasAreLoading } = useGetAreasQuery();
  const [orders, setOrders] = useState([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [syncOrders] = useUpdateOrdersMutation();

  useEffect(() => {
    if (game) {
      setOrders(game.orders);
    }
  }, [game]);

  if (gameIsLoading || areasAreLoading) {
    return <div>Loading</div>;
  }

  const { positions } = game;
  const positionsById = groupById(positions);
  const areasById = groupById(areas, 'name');

  const updateOrder = (index, order) => {
    const updatedOrders = [...orders];
    updatedOrders[index] = order;
    setOrders(updatedOrders);
  };

  const submitOrders = async () => {
    setIsSubmitting(true);
    const result = await syncOrders({ gameId: game.id, orders }).unwrap();
    setIsSubmitting(false);
    console.log(result);
  }

  return (
    <div className="flex min-h-screen">
      <div className="w-[45%] p-8">
        <h1 className="text-xl mb-8">Game: {game.name}</h1>
        <h2 className="text-l mb-8">Turn: {game.turn.type}</h2>
        {orders.map((order, index) => (
          <OrderInput
            key={index}
            areas={areas}
            areasById={areasById}
            order={order}
            position={positionsById[order.id]}
            resolution={[]}
            updateOrder={partial(updateOrder, index)}
          />
        ))}
        <div className="flex w-full justify-end my-6">
          <Button isLoading={isSubmitting} onClick={submitOrders} text="Submit Orders" />
        </div>
      </div>
      <div className="w-[55%]">
        <Map positions={positions} areasById={areasById} />
      </div>
    </div>
  );
}
