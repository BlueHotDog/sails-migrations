const configLoader = require('./config_loader.js');
const knex = require('knex');

function load() {
  return configLoader.load().then(function(config) {
    //probably a good idea to wrap this with something to abstract knex
    return knex(config).migrate;
  });

}

exports.load = load;