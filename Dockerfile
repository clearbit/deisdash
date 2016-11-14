FROM library/node

WORKDIR /app
ENV PORT 5000
EXPOSE 5000
CMD ["node", "server.js"]

ADD package.json /app
RUN npm install
ADD . /app
