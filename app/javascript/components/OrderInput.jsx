import React from 'react';
import { capitalize, isUndefined, partialRight } from 'lodash';
import { ORDER_TYPES, UNIT_TYPES } from '../const';
import Select from './Select';

const allowableOrderTypes = (turn, unitType = null) => {
  if (['fall', 'spring'].includes(turn.type)) {
    return (unitType === UNIT_TYPES.FLEET) ? [ORDER_TYPES.HOLD, ORDER_TYPES.MOVE, ORDER_TYPES.SUPPORT, ORDER_TYPES.CONVOY] : [ORDER_TYPES.HOLD, ORDER_TYPES.MOVE, ORDER_TYPES.SUPPORT];
  } else if (['fall_retreat', 'spring_retreat'].includes(turn.type)) {
    return [ORDER_TYPES.DISBAND, ORDER_TYPES.RETREAT];
  } else if (turn.type === 'winter') {
    // TODO: only allow building appropriate type based on area
    return [ORDER_TYPES.BUILD_ARMY, ORDER_TYPES.BUILD_FLEET];
  } else {
    throw new Error(`Unsupported turn type: ${turn.type}`);
  }
};

const orderConfirmable = order => order.orderType && order.areaFromId && order.areaToId;

export default function OrderInput({ areas, areasById, order, player, position, turn, updateOrder }) {
  const onChange = (event, value) => {
    const updatedOrder = { ...order, [event.target.name]: isUndefined(value) ? event.target.value : value };
    if (event.target.name === 'orderType') {
      updatedOrder.areaFromId = null;
      updatedOrder.areaToId = null;
    }
    if (updatedOrder.orderType === ORDER_TYPES.HOLD) {
      updatedOrder.areaFromId = position.areaId;
      updatedOrder.areaToId = position.areaId;
    }
    if (updatedOrder.orderType === ORDER_TYPES.MOVE) {
      updatedOrder.areaFromId = position.areaId;
    }
    if (event.target.name !== 'confirmed') {
      updatedOrder.confirmed = false;
    }
    updateOrder(updatedOrder);
  };

  return (
    <div className="flex items-center gap-x-2 mb-4">
      <div className='w-20 text-sm'>
        {capitalize(player.nationality)}
      </div>
      <div className='w-20 text-sm'>
        {capitalize(position.unitType)}
      </div>
      <div className='w-24 text-sm'>
        {areasById[position.areaId]}
      </div>
      <div>
        <input
          type="checkbox"
          name="confirmed"
          checked={order.confirmed}
          className="accent-amber-300"
          disabled={!orderConfirmable(order)}
          onChange={partialRight(onChange, !order.confirmed)}
        />
      </div>
      <Select className="w-20" name="orderType" value={order.orderType || '0'} onChange={onChange}>
        {!order.orderType && <option value="0" disabled>Order</option>}
        {allowableOrderTypes(turn, position.unitType).map(orderType => (
          <option key={orderType} value={orderType}>{capitalize(orderType)}</option>
        ))}
      </Select>
      {([ORDER_TYPES.SUPPORT, ORDER_TYPES.CONVOY].includes(order.orderType)) && (
        <Select className="w-24" name="areaFromId" value={order.areaFromId || '0'} onChange={onChange}>
          {!order.areaFromId && <option value="0" disabled>From</option>}
          {Object.values(areas).map(area => <option key={area.id} value={area.id}>{area.name}</option>)}
        </Select>
      )}
      {([ORDER_TYPES.MOVE, ORDER_TYPES.SUPPORT, ORDER_TYPES.CONVOY, ORDER_TYPES.RETREAT].includes(order.orderType)) && (
        <Select className="w-24" name="areaToId" value={order.areaToId || '0'} onChange={onChange}>
          {!order.areaToId && <option value="0" disabled>To</option>}
          {Object.values(areas).map(area => <option key={area.id} value={area.id}>{area.name}</option>)}
        </Select>
      )}
    </div>
  );
}
