require('coffee-script');

var path = require('path');
var databaseTasks = rek("lib/sails-migrations/database_tasks.coffee");
var sailsIntegration = rek("lib/sails-migrations/sails_integration.coffee");

describe("database tasks", function() {
  return it("should work", function(done) {
    var modulesPath = path.resolve("test/example_app/node_modules");
    sailsIntegration.loadSailsConfig(modulesPath, function(err,config){
      databaseTasks.create(config.defaultAdapter, function(err) {
        console.log(err)
        done();
      })
    })
  });
});
