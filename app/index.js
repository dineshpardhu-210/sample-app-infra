const http = require('http');
const PORT = 3000;
const server = http.createServer((req, res) => {
  res.end(`Hey there, your sample-app is up and running Time: ${new Date()}\n`);
});
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));

