import * as BookController from './books/controller.js';

/**
 * @type {import('@hapi/hapi').ServerRoute[]}
 */
const routes = [
  {
    method: 'GET',
    path: '/books',
    handler: BookController.getAll,
  },
  {
    method: 'GET',
    path: '/books/{id}',
    handler: BookController.get,
  },
  {
    method: 'POST',
    path: '/books',
    handler: BookController.create,
  },
  {
    method: 'PUT',
    path: '/books/{id}',
    handler: BookController.update,
  },
  {
    method: 'DELETE',
    path: '/books/{id}',
    handler: BookController.delete,
  },
];

// listing routes
routes.unshift({
  method: 'GET',
  path: '/',
  handler: () => routes.map((route) => `${route.method} ${route.path}`),
});

export default routes;
