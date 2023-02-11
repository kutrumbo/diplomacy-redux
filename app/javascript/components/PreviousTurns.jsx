import React from 'react';
import { Disclosure } from '@headlessui/react'
import { groupBy, orderBy, startCase } from 'lodash';
import Badge from './Badge';
import { turnYear } from '../utils';
import { RESOLUTIONS } from '../const';

function OrderDisplay({ areasById, order, playersById }) {
  return (
    <div className="flex items-center gap-x-2 mb-2 text-sm">
      <div className="w-16">{startCase(playersById[order.position.playerId].nationality)}</div>
      <div className="w-16">{startCase(order.orderType)}</div>
      <div className="w-24">{areasById[order.areaFromId]}</div>
      <div className="w-24">{areasById[order.areaToId]}</div>
      <div className="w-24">
        <Badge
          success={order.resolution === RESOLUTIONS.SUCCESS}
          danger={order.resolution === RESOLUTIONS.FAIL}
          text={startCase(order.resolution)}
        />
      </div>
    </div>
  );
}

function TurnDisplay({ areasById, orders, playersById, turn }) {
  const orderedOrders = orderBy(orders, o => playersById[o.position.playerId].nationality);

  return (
    <Disclosure as="div">
      <Disclosure.Button className="bg-blue-100 hover:bg-blue-200 rounded p-2 mb-2">
        {startCase(turn.type)} {turnYear(turn)}
      </Disclosure.Button>
      <Disclosure.Panel as="div" className="mb-2">
        {orderedOrders.length ? orderedOrders.map(order => (
          <OrderDisplay key={order.id} areasById={areasById} order={order} playersById={playersById} />
        )) : (
          <div>No orders this turn</div>
        )}
      </Disclosure.Panel>
    </Disclosure>
  );
}

export default function PreviousTurns({ areasById, pastOrders, playersById, turns }) {
  const orderedTurns = orderBy(turns, 'number', 'desc');
  const ordersByTurn = groupBy(pastOrders, 'position.turnId');

  return (
    <>
      {orderedTurns.map(turn => (
        <TurnDisplay
          key={turn.id}
          areasById={areasById}
          orders={ordersByTurn[turn.id]}
          playersById={playersById}
          turn={turn}
        />
      ))}
    </>
  );
}
