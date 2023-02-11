import React, { useState } from 'react';
import { partial } from 'lodash';
import { useAdjudicateOrdersMutation, useGetAreasQuery } from '../api';
import { groupById } from '../utils';
import Button from '../components/Button';
import SandboxOrderInput from '../components/SandboxOrderInput';
import Map from '../components/Map';
import { NATIONALITIES } from '../const';

const PLAYER_ID_MAP = Object.values(NATIONALITIES).reduce((obj, nationality, index) => {
  obj[index] = { nationality };
  return obj;
}, {});

const PLAYER_ID_BY_NATIONALITY = Object.values(NATIONALITIES).reduce((obj, nationality, index) => {
  obj[nationality] = index;
  return obj;
}, {});

export default function Sandbox() {
  const [orders, setOrders] = useState([{ id: 1 }])
  const [resolutions, setResolutions] = useState({});
  const { data: areas = [] } = useGetAreasQuery();
  const [adjudicateOrders] = useAdjudicateOrdersMutation();

  const positions = orders.filter(order => order.nationality && order.unitType && order.areaId);
  const areasById = groupById(areas, 'name');

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
  };

  return (
    <div className="flex min-h-screen">
      <div className="w-[45%] p-8">
        <h1 className="text-xl mb-8">Sandbox</h1>
        {orders.map((order, index) => (
          <SandboxOrderInput
            key={index}
            areas={areas}
            order={order}
            orders={orders}
            removeOrder={partial(removeOrder, index)}
            resolution={resolutions[index + 1]}
            updateOrder={partial(updateOrder, index)}
            playerIdByNationality={PLAYER_ID_BY_NATIONALITY}
          />
        ))}
        <Button onClick={addOrder} text="Add Order" neutral small />
        <div className="flex w-full justify-end my-6">
          <Button onClick={submitOrders} text="Submit Orders" />
        </div>
      </div>
      <div className="w-[55%]">
        <Map positions={positions} areasById={areasById} playersById={PLAYER_ID_MAP} />
      </div>
    </div>
  );
}
