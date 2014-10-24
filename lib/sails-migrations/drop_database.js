const databaseTasks = require('./helpers/database_tasks.js');
const Promise = require('bluebird');
const ConfigLoader = require('./helpers/config_loader.js');


function dropDatabase(){
  return ConfigLoader.load().then(function(config){
    return Promise.promisify(databaseTasks.drop)(config).then(function(config) {
      return config;
    });
  });
}

module.exports = dropDatabase;