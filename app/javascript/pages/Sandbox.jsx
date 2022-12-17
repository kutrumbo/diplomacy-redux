import React, { useState } from 'react';
import { partial, sortBy } from 'lodash';
import { useGetAreasQuery } from '../api';
import Button from '../components/Button';
import OrderInput from '../components/OrderInput';

export default function Sandbox() {
  const { data: areas = [] } = useGetAreasQuery();
  const [orders, setOrders] = useState([{}])

  const sortedAreas = sortBy(areas, 'name');

  const updateOrder = (index, order) => {
    orders[index] = order;
    setOrders([...orders]);
  };

  return (
    <div className="min-h-screen bg-slate-100">
      <div className="min-h-screen mx-36 p-12 bg-white shadow-xl">
        <h1 className="text-xl mb-8">Sandbox</h1>
        {orders.map((order, index) => <OrderInput key={index} areas={sortedAreas} order={order} updateOrder={partial(updateOrder, index)} />)}
        <Button onClick={() => setOrders([...orders, {}])} text="Add Order" />
        <Button className="mt-6" onClick={() => {}} text="Submit Orders" />
      </div>
    </div>
  );
}
