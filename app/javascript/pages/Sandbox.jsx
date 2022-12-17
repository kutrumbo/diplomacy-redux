import React, { useState } from 'react';
import { partial, sortBy } from 'lodash';
import { useAdjudicateOrdersMutation, useGetAreasQuery } from '../api';
import Button from '../components/Button';
import OrderInput from '../components/OrderInput';
import Map from '../components/Map';

export default function Sandbox() {
  const [orders, setOrders] = useState([{ id: 1 }])
  const [resolutions, setResolutions] = useState({});
  const { data: areas = [] } = useGetAreasQuery();
  const [adjudicateOrders] = useAdjudicateOrdersMutation();

  const positions = orders.filter(order => order.nationality && order.unitType && order.area);
  const areasById = areas.reduce((obj, area) => {
    obj[area.id] = area.name;
    return obj;
  }, {});

  const sortedAreas = sortBy(areas, 'name');

  const updateOrder = (index, order) => {
    orders[index] = order;
    setOrders([...orders]);
  };

  const submitOrders = async () => {
    const adjudications = await adjudicateOrders({ orders }).unwrap();
    const resolutionsById = adjudications.reduce((resolutions, adjudication) => {
      resolutions[adjudication.id] = adjudication.resolution;
      return resolutions;
    }, {});
    setResolutions(resolutionsById);
  }

  return (
    <div className="min-h-screen bg-slate-100">
      <div className="min-h-screen mx-36 p-12 bg-white shadow-xl">
        <h1 className="text-xl mb-8">Sandbox</h1>
        {orders.map((order, index) => (
          <OrderInput
            key={index}
            areas={sortedAreas}
            order={order}
            updateOrder={partial(updateOrder, index)}
            resolution={resolutions[index + 1]}
          />
        ))}
        <Button onClick={() => setOrders([...orders, { id: orders.length + 1 }])} text="Add Order" />
        <Button className="my-6" onClick={submitOrders} text="Submit Orders" />
        <Map positions={positions} areasById={areasById} />
      </div>
    </div>
  );
}
