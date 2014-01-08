process.env.NODE_ENV = "test"
GLOBAL.rek = function(file) {
  return require(__dirname + "/../" + file)
};

process.on('uncaughtException', function (err) {
  console.log(err);
});
