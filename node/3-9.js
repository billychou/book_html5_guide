var http = require("http")
var opts = {
    host: "m5.amap.com",
    port: 80,
    path: "/"
}

try {
    http.get(opts, function(res){
        console.log("Will this get called?");
        console.log(res);
    })
}

catch (e) {
    console.log("Will we catch an error?");
}
