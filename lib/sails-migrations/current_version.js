const knex = require('knex');
const Promise = require('bluebird');
const ConfigLoader = require('./helpers/config_loader.js');


function currentVersion(){
  return ConfigLoader.load().then(function(config){
    return knex(config).migrate.currentVersion();
  });
}

module.exports = currentVersion;