# Stage 1: Build stage
FROM node:24-bookworm-slim AS build

# Install build dependencies for native modules (isolated-vm, sqlite3)
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 g++ build-essential libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy yarn and package configurations
COPY .yarn ./.yarn
COPY .yarnrc.yml package.json yarn.lock backstage.json ./
COPY packages/app/package.json ./packages/app/package.json
COPY packages/backend/package.json ./packages/backend/package.json

# Install dependencies (without devDependencies for production, but we need them for build)
RUN yarn install --immutable

# Copy the rest of the source code
COPY . .

# Build the app and backend
RUN yarn build:all

# Stage 2: Production stage
FROM node:24-bookworm-slim

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends libsqlite3-0 python3 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the built assets from the build stage
COPY --from=build /app/package.json /app/yarn.lock /app/backstage.json ./
COPY --from=build /app/packages/backend/dist ./packages/backend/dist
COPY --from=build /app/packages/backend/node_modules ./packages/backend/node_modules
COPY --from=build /app/packages/app/dist ./packages/app/dist
COPY --from=build /app/app-config.yaml /app/app-config.production.yaml ./
COPY --from=build /app/examples ./examples

# Create data directory for SQLite
RUN mkdir -p data && chown -R node:node /app

USER node

# Production environment variables
ENV NODE_ENV=production
ENV NODE_OPTIONS="--no-node-snapshot"

# Expose backend port
EXPOSE 7007

# Start Backstage
CMD ["node", "packages/backend/dist/index.cjs.js", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
