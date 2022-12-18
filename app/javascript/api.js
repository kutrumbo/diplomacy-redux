import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react'
import { camelCaseKeys, snakeCaseKeys } from './utils';

export const api = createApi({
  reducerPath: 'api',
  baseQuery: fetchBaseQuery({
    baseUrl: '/api/',
    prepareHeaders(headers) {
      const csrfToken = document.querySelector('[name=csrf-token]').content;
      headers.set('X-CSRF-TOKEN', csrfToken);
      headers.set('Accept', 'application/json');

      return headers;
    },
  }),
  endpoints: (builder) => ({
    adjudicateOrders: builder.mutation({
      query: orders => ({
        url: 'orders/adjudicate',
        method: 'POST',
        body: snakeCaseKeys(orders),
      }),
      transformResponse: response => camelCaseKeys(response),
    }),
    getAreas: builder.query({
      query: () => 'areas',
      transformResponse: response => camelCaseKeys(response),
    }),
    getGame: builder.query({
      query: (id) => `games/${id}`,
      transformResponse: response => camelCaseKeys(response),
    }),
  }),
});

export const { useAdjudicateOrdersMutation, useGetAreasQuery, useGetGameQuery } = api;
