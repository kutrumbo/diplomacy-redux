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

  const addOrder = () => {
    setResolutions([]);
    setOrders([...orders, { id: orders.length + 1 }]);
  };

  const removeOrder = (index) => {
    setResolutions([]);
    orders.splice(index, 1);
    setOrders([...orders]);
  };

  const updateOrder = (index, order) => {
    setResolutions([]);
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
    <div className="flex min-h-screen">
      <div className="w-[45%] p-8">
        <h1 className="text-xl mb-8">Sandbox</h1>
        {orders.map((order, index) => (
          <OrderInput
            key={index}
            areas={sortedAreas}
            order={order}
            orders={orders}
            removeOrder={partial(removeOrder, index)}
            resolution={resolutions[index + 1]}
            updateOrder={partial(updateOrder, index)}
          />
        ))}
        <Button onClick={addOrder} text="Add Order" neutral small />
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
