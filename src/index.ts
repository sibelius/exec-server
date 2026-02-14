import { createServer } from 'http';
import { app } from './app.ts'

const PORT = parseInt(process.env.EXEC_SERVER_PORT || '7771', 10);
const HOST = process.env.EXEC_SERVER_HOST || '127.0.0.1';

const requestListener = app.callback();

const server = createServer(requestListener);

server.listen(PORT, HOST, () => {
  console.log(`Server started on http://${HOST}:${PORT}`);
});