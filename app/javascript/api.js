import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react'

export const api = createApi({
  reducerPath: 'api',
  baseQuery: fetchBaseQuery({ baseUrl: '/api/' }),
  endpoints: (builder) => ({
    getAreas: builder.query({
      query: () => 'areas',
    }),
  }),
});

export const { useGetAreasQuery } = api;
