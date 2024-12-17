import Router from '@koa/router';
import { exec } from "child_process";
import util from "util";

const execPromise = util.promisify(exec);
export const router = new Router();

router.all('/', async (ctx, next) => {
  ctx.status = 200;
  ctx.body = 'working';
});

router.all('/exec', async (ctx, next) => {
  const command = ctx.query.command as string; // Get the command from the query string

  console.log({ command });

  if (!command) {
    ctx.status = 400;
    ctx.body = { error: "Command is required. Provide it as a query parameter, e.g., ?command=ls" };
    return;
  }

  const decodedCommand = decodeURIComponent(command);
  console.log({ decodedCommand });

  // Function to execute the command with Promise
  const execWithTimeout = (cmd: string, timeoutMs: number) => {
    return Promise.race([
      execPromise(cmd), // Main execution
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error("Command execution timed out")), timeoutMs)
      ),
    ]);
  };

  try {
    const { stdout, stderr } = await execWithTimeout(decodedCommand, 10000); // 10 seconds timeout
    ctx.status = 200;
    ctx.body = {
      success: true,
      stdout,
      stderr,
    };
  } catch (error: any) {
    console.log({ error });

    if (error.message === "Command execution timed out") {
      ctx.status = 408; // Request Timeout
      ctx.body = { success: false, error: error.message };
    } else {
      ctx.status = 500;
      ctx.body = { success: false, error: error.message };
    }
  }
});
