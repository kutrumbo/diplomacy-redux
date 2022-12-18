import React from 'react';
import { capitalize } from 'lodash';
import { NATIONALITIES, ORDER_TYPES, RESOLUTIONS, UNIT_TYPES } from '../const';
import Badge from './Badge';
import Button from './Button';
import Select from './Select';

function ResolutionBadge({ resolution }) {
  return (
    <Badge
      success={resolution === RESOLUTIONS.SUCCESS}
      danger={resolution === RESOLUTIONS.FAIL}
      text={resolution}
    />
  );
}

export default function OrderInput({ areas, order, orders, resolution, removeOrder, updateOrder }) {

  const onChange = (event) => {
    const updatedOrder = { ...order, [event.target.name]: event.target.value };
    if (event.target.name === 'orderType') {
      updatedOrder.areaFrom = null;
      updatedOrder.areaTo = null;
    }
    if (updatedOrder.orderType === ORDER_TYPES.HOLD) {
      updatedOrder.areaFrom = updatedOrder.areaId;
      updatedOrder.areaTo = updatedOrder.areaId;
    }
    if (updatedOrder.orderType === ORDER_TYPES.MOVE) {
      updatedOrder.areaFrom = updatedOrder.areaId;
    }
    updateOrder(updatedOrder);
  };

  return (
    <div className="flex items-center gap-x-2 mb-4">
      <Select className="w-24" name="nationality" value={order.nationality || '0'} onChange={onChange}>
        {!order.nationality && <option value="0" disabled>Nationality</option>}
        {Object.values(NATIONALITIES).map(nationality => <option key={nationality} value={nationality}>{capitalize(nationality)}</option>)}
      </Select>
      <Select className="w-20" name="unitType" value={order.unitType || '0'} onChange={onChange}>
        {!order.unitType && <option value="0" disabled>Unit Type</option>}
        {Object.values(UNIT_TYPES).map(unitType => <option key={unitType} value={unitType}>{capitalize(unitType)}</option>)}
      </Select>
      <Select className="w-24" name="areaId" value={order.areaId || '0'} onChange={onChange}>
        {!order.areaId && <option value="0" disabled>Area</option>}
        {Object.values(areas).map(area => <option key={area.id} value={area.id}>{area.name}</option>)}
      </Select>
      <Select className="w-20" name="orderType" value={order.orderType || '0'} onChange={onChange}>
        {!order.orderType && <option value="0" disabled>Order</option>}
        {Object.values(ORDER_TYPES).map(orderType => <option key={orderType} value={orderType}>{capitalize(orderType)}</option>)}
      </Select>
      {([ORDER_TYPES.SUPPORT, ORDER_TYPES.CONVOY].includes(order.orderType)) && (
        <Select className="w-24" name="areaFrom" value={order.areaFrom || '0'} onChange={onChange}>
          {!order.areaFrom && <option value="0" disabled>From</option>}
          {Object.values(areas).map(area => <option key={area.id} value={area.id}>{area.name}</option>)}
        </Select>
      )}
      {([ORDER_TYPES.MOVE, ORDER_TYPES.SUPPORT, ORDER_TYPES.CONVOY].includes(order.orderType)) && (
        <Select className="w-24" name="areaTo" value={order.areaTo || '0'} onChange={onChange}>
          {!order.areaTo && <option value="0" disabled>To</option>}
          {Object.values(areas).map(area => <option key={area.id} value={area.id}>{area.name}</option>)}
        </Select>
      )}
      {(orders.length !== 1) && <Button text={'\u2715'} danger small onClick={removeOrder} />}
      {resolution && <ResolutionBadge resolution={resolution} /> }
    </div>
  );
}
