import Hapi from '@hapi/hapi';
import routes from './routes.js';

const createServer = async () => {
  const server = Hapi.server({
    port: 3000,
    host: 'localhost',
    routes: {
      cors: {
        origin: ['*'],
      },
    },
  });

  server.route(routes);

  await server.start();
  console.log('Server running on %s', server.info.uri);

  return server;
};

export default createServer;
