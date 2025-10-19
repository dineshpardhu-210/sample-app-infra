FROM node:18-alpine
WORKDIR /usr/src/app
COPY app/package.json ./
RUN npm install --production
COPY app/ ./app
ENV PORT=3000
EXPOSE 3000
CMD ["node", "app/index.js"]
