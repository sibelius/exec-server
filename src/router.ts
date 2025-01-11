import Router from '@koa/router';

import { exec } from "child_process";
import util from "util";
const execPromise = util.promisify(exec);

export const router = new Router();

router.all('/', async (ctx, next) => {
  ctx.status = 200;
  ctx.body = 'working';
})
router.all('/exec', async (ctx, next) => {
  // exec this command
  const command = ctx.query.command as string; // Get the command from the query string

  console.log({
    command,
  })

  if (!command) {
    ctx.status = 400;
    ctx.body = { error: "Command is required. Provide it as a query parameter, e.g., ?command=ls" };
    return;
  }

  const decodedCommand = decodeURIComponent(command);

  console.log({
    decodedCommand
  })

  const timeout = new Promise<never>((_, reject) => 
    setTimeout(() => reject(new Error('Command execution timed out after 30 seconds')), 30000)
  );

  try {
    const { stdout, stderr } = await Promise.race([
      execPromise(decodedCommand),
      timeout
    ]);
    ctx.status = 200;
    ctx.body = {
      success: true,
      stdout,
      stderr,
    };
  } catch (error) {
    console.log({
      error,
    });
    ctx.status = 500;
    ctx.body = {
      success: false,
      error: error.message,
    };
  }
})