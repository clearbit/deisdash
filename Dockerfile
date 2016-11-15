FROM library/node

WORKDIR /app

ENV NPM_CONFIG_PRODUCTION false
ENV NODE_ENV production
ENV PORT 5000

EXPOSE 5000
CMD ["node", "server.js"]

ADD package.json /app
RUN npm install
ADD . /app
