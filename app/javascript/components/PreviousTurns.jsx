import React from 'react';
import { Disclosure } from '@headlessui/react'
import { groupBy, orderBy, startCase } from 'lodash';
import { turnYear } from '../utils';

function TurnDisplay({ areasById, orders, playersById, turn }) {
  const orderedOrders = orderBy(orders, o => playersById[o.position.playerId].nationality);

  return (
    <Disclosure as="div">
      <Disclosure.Button className="py-2">
        {startCase(turn.type)} {turnYear(turn)}
      </Disclosure.Button>
      <Disclosure.Panel className="text-gray-500">
        {orderedOrders.length ? orderedOrders.map(order => (
          <div key={order.id}>{order.orderType}</div>
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
