Day6 task


 Index .js file


const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
    res.send('Hello, Kubernetes!');
});

app.listen(port, () => {
    console.log(`App running at http://localhost:${port}`);
});

app.get('/newroute', (req, res) => {
    res.send('This is a new route!');
});



Dockerfile

FROM node:14
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "index.js"]


package.json

{
  "name": "nodejs-k8s-project",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.19.2"
  }
}

Perfomed task image1


![alt text](<Screenshot from 2024-07-18 15-28-21.png>)

perfomed task image2


![alt text](<Screenshot from 2024-07-18 15-28-26.png>)

performed task image3

![alt text](<Screenshot from 2024-07-18 15-28-34.png>)


performed task image4

![alt text](<Screenshot from 2024-07-18 15-28-47.png>)

performed task image5

![alt text](<Screenshot from 2024-07-18 15-51-10.png>)