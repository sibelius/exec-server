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
})();