const knex = require('knex');
const Promise = require('bluebird');
const ConfigLoader = require('./helpers/config_loader.js');


function rollback(){
  return ConfigLoader.load().then(function(config){
    return knex(config).migrate.rollback();
  });
}

module.exports = rollback;