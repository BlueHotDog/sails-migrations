const databaseTasks = require('./helpers/database_tasks.js');
const Promise = require('bluebird');
const ConfigLoader = require('./helpers/config_loader.js');


function createDatabase() {
  return ConfigLoader.load().then(function(config){
    return Promise.promisify(databaseTasks.create)(config).then(function() {
      return config;
    })
  })
}

module.exports = createDatabase;