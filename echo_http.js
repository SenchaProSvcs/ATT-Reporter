var express = require('express');
var app = express.createServer();

app.get('*', function(req, res){
    // console.log(req.headers)
    console.log(req)
    res.send('OK');
});

app.listen(3000);