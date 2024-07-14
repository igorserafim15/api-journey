FROM node:20-alpine3.19 AS base

# Install pnpm
RUN npm i -g pnpm

# Dependencies
FROM base AS dependencies

WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install

# Builder
FROM base AS builder

WORKDIR /app
COPY . .
COPY --from=dependencies /app/node_modules ./node_modules
RUN pnpm build
RUN pnpm prune --prod

# Deploy
FROM base AS deploy

WORKDIR /app
RUN npm i -g pnpm prisma
COPY --from=builder /app/build ./build
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/prisma ./prisma
RUN pnpm prisma generate

EXPOSE 	3333

CMD [ "pnpm", "start:prod" ]

