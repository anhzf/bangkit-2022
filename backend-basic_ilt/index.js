const Hapi = require('@hapi/hapi');

const getUsers = () => require('./data');

const init = async () => {

  const server = Hapi.server({
    port: 3000,
    host: 'localhost'
  });

  server.route([{
    method: 'GET',
    path: '/users',
    handler: (req, h) => getUsers()
  }, {
    method: 'GET',
    path: '/users/{id}',
    handler: (req, h) => {
      const user = getUsers().find(user => user.id == req.params.id);
      return user;
    },
  }, {
    method: 'POST',
    path: '/users',
    handler: (req, h) => {
      if ([typeof req.payload.id, typeof req.payload.email, typeof req.payload.name].includes('undefined')) {
        return h.response({
          status: 'error',
          message: 'Missing parameters'
        }).code(400);
      }

      const users = getUsers();
      const isExists = users.find(user => user.id == req.payload.id);
      if (isExists) {
        return h.response({
          message: 'User already exists'
        }).code(400);
      }
      const user = {
        id: req.payload.id,
        name: req.payload.name,
        email: req.payload.email
      };
      users.push(user);
      return {
        status: 'success',
        message: 'User created',
        user
      };
    }
  }, {
    method: 'PUT',
    path: '/users/{id}',
    handler: (req, h) => {
      const users = getUsers();
      const user = users.find(user => user.id == req.params.id);
      if (!user) {
        return h.response({
          status: 'error',
          message: 'User not found'
        }).code(400);
      }
      if (typeof req.payload.email != 'undefined') {
        user.email = req.payload.email;
      }
      if (typeof req.payload.name != 'undefined') {
        user.name = req.payload.name;
      }
      return {
        status: 'success',
        message: 'User updated',
        user
      };
    }
  }, {
    method: 'DELETE',
    path: '/users/{id}',
    handler: (req, h) => {
      const users = getUsers();
      const user = users.find(user => user.id == req.params.id);
      if (!user) {
        return h.response({
          status: 'error',
          message: 'User not found'
        }).code(400);
      }
      users.splice(users.indexOf(user), 1);
      return {
        status: 'success',
        message: `User ${user.id} deleted`
      };
    }
  }]);

  await server.start();
  console.log('Server running on %s', server.info.uri);
};

process.on('unhandledRejection', (err) => {
  console.log(err);
  process.exit(1);
});

init();