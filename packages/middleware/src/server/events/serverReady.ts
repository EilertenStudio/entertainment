import {Server} from "../index.js"

export default (server: Server) => {

  server.once('listening', () => {
    console.log('[server.listening]', 'Server online');
  });

};