import React from 'react';
import { capitalize } from 'lodash';
import { NATIONALITIES, ORDER_TYPES, UNIT_TYPES } from '../const';
import Select from './Select';

export default function OrderInput({ areas, order, resolution, updateOrder }) {

  const onChange = (event) => {
    const updatedOrder = { ...order, [event.target.name]: event.target.value };
    if (event.target.name === 'orderType') {
      updatedOrder.areaFrom = null;
      updatedOrder.areaTo = null;
    }
    if (updatedOrder.orderType === ORDER_TYPES.HOLD) {
      updatedOrder.areaFrom = updatedOrder.area;
      updatedOrder.areaTo = updatedOrder.area;
    }
    if (updatedOrder.orderType === ORDER_TYPES.MOVE) {
      updatedOrder.areaFrom = updatedOrder.area;
    }
    updateOrder(updatedOrder);
  };

  return (
    <div className="flex gap-x-6 mb-4">
      <Select name="nationality" value={order.nationality || '0'} onChange={onChange}>
        {!order.nationality && <option value="0" disabled>Nationality</option>}
        {Object.values(NATIONALITIES).map(nationality => <option key={nationality} value={nationality}>{capitalize(nationality)}</option>)}
      </Select>
      <Select name="unitType" value={order.unitType || '0'} onChange={onChange}>
        {!order.unitType && <option value="0" disabled>Unit Type</option>}
        {Object.values(UNIT_TYPES).map(unitType => <option key={unitType} value={unitType}>{capitalize(unitType)}</option>)}
      </Select>
      <Select name="area" value={order.area || '0'} onChange={onChange}>
        {!order.area && <option value="0" disabled>Area</option>}
        {Object.values(areas).map(area => <option key={area.id} value={area.id}>{area.name}</option>)}
      </Select>
      <Select name="orderType" value={order.orderType || '0'} onChange={onChange}>
        {!order.orderType && <option value="0" disabled>Order Type</option>}
        {Object.values(ORDER_TYPES).map(orderType => <option key={orderType} value={orderType}>{capitalize(orderType)}</option>)}
      </Select>
      {([ORDER_TYPES.SUPPORT, ORDER_TYPES.CONVOY].includes(order.orderType)) && (
        <Select name="areaFrom" value={order.areaFrom || '0'} onChange={onChange}>
          {!order.areaTo && <option value="0" disabled>From</option>}
          {Object.values(areas).map(area => <option key={area.id} value={area.id}>{area.name}</option>)}
        </Select>
      )}
      {([ORDER_TYPES.MOVE, ORDER_TYPES.SUPPORT, ORDER_TYPES.CONVOY].includes(order.orderType)) && (
        <Select name="areaTo" value={order.areaTo || '0'} onChange={onChange}>
          {!order.areaTo && <option value="0" disabled>To</option>}
          {Object.values(areas).map(area => <option key={area.id} value={area.id}>{area.name}</option>)}
        </Select>
      )}
      {resolution}
    </div>
  );
}
