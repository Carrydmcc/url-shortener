FROM node:22-alpine

ENV NODE_ENV=production

WORKDIR /kutt

RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

RUN mkdir -p /var/lib/kutt

COPY . .

EXPOSE 5535

CMD npm run migrate && npm start