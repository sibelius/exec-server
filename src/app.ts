import Koa from 'koa';
import bodyParser from 'koa-bodyparser';
import koaLogger from 'koa-logger';
import { router} from './router.ts'

export const app = new Koa({
  proxy: true,
});

app.use(
  bodyParser({
    onerror(err, ctx) {
      // http-errors deprecated non-first-argument status code; replace with createError(422, ...)
      // ctx.throw(createHttpError(422, err));
      ctx.throw(err, 422);
    },
  }),
);
app.use(koaLogger());

app.on('error', (err, ctx) => {
  // eslint-disable-next-line
  console.log('koa err: ', err);
});

app.use(router.routes()).use(router.allowedMethods());
