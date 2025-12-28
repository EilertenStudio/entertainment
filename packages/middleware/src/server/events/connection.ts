import {Server} from "../index.js"

export default (server: Server) => {

  server.on('connection', (client) => {
    console.log('[server.connection]', 'Client connected')//,  client);

    // console.log('[server.connection]', server.clients);

    client.on('error', (error) => {
      console.error('[server.error]', error)
    });

    client.on('close', (code, reason) => {
      console.log('[server.close]', `Client disconnected (code: ${code}) (reason: ${reason})`);
    })

  });

};