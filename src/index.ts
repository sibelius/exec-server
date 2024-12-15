import { createServer } from 'http';
import { app } from './app.ts'

let requestListener = app.callback();

const PORT = 7771;

(async () => {
  console.log('working')

  const server = createServer(requestListener);

  server.listen(PORT, () => {
    // eslint-disable-next-line
    console.log(`Server started on port http://localhost:${PORT}`);
  });

  // figure this out
  // if (module.hot) {
  //   module.hot.accept();
  //
  //   module.hot.accept(['./app'], () => {
  //     console.log('🔁  HMR Reloading `./app`...');
  //
  //     if (server) {
  //       // replace request handler of server
  //       server.removeListener('request', requestListener);
  //       const newApp = require('./app');
  //
  //       requestListener = newApp.default.callback();
  //
  //       server.on('request', requestListener);
  //     }
  //   });
  //
  //   module.hot.dispose(() => {
  //     console.log('hmr dispose');
  //     if (server) {
  //       server.close();
  //     }
  //   });
  // }
})();