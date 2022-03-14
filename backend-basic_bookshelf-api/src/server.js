import Hapi from '@hapi/hapi';
import routes from './routes.js';
import { clearDebugValue } from './utils/dev.js';

const createServer = async () => {
  const server = Hapi.server({
    port: process.env.PORT || 3000,
    host: process.env.HOST || 'localhost',
    routes: {
      cors: { origin: ['*'] },
    },
  });

  server.route(routes);

  server.events.on('request', clearDebugValue);

  await server.start();
  console.log('Server running on %s', server.info.uri);

  return server;
};

export default createServer;
