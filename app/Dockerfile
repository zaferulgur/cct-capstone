FROM node:18.17-slim

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

RUN node seedDB/category-seed.js
RUN node seedDB/products-seed.js

CMD [ "npm", "start" ]
