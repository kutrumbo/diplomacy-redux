import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react'
import { pick, sortBy } from 'lodash';
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
  tagTypes: ['Game'],
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
      transformResponse: response => sortBy(camelCaseKeys(response), 'name'),
    }),
    getGame: builder.query({
      query: (id) => `games/${id}`,
      transformResponse: response => camelCaseKeys(response),
      providesTags: ['Game'],
    }),
    updateOrders: builder.mutation({
      query: ({ gameId, orders }) => ({
        url: `games/${gameId}/orders`,
        method: 'PUT',
        body: snakeCaseKeys({ orders }),
      }),
      transformResponse: response => camelCaseKeys(response),
      invalidatesTags: ['Game'],
    }),
  }),
});

export const { useAdjudicateOrdersMutation, useGetAreasQuery, useGetGameQuery, useUpdateOrdersMutation } = api;
