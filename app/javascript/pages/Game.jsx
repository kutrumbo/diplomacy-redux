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
  const { data: game, isLoading: gameIsLoading, refetch: refetchGame } = useGetGameQuery(gameId);
  const { data: areas, isLoading: areasAreLoading } = useGetAreasQuery();
  const [orders, setOrders] = useState([])
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
    const result = await syncOrders({ gameId: game.id, orders }).unwrap();
    console.log(result);
  }

  return (
    <div className="flex min-h-screen">
      <div className="w-[45%] p-8">
        <h1 className="text-xl mb-8">{game.name}</h1>
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
          <Button onClick={submitOrders} text="Submit Orders" />
        </div>
      </div>
      <div className="w-[55%]">
        <Map positions={positions} areasById={areasById} />
      </div>
    </div>
  );
}
