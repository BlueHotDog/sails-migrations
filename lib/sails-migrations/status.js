const knex = require('knex');
const ConfigLoader = require('./helpers/config_loader.js');


function status() {
  return ConfigLoader.load().then(function (config) {
    var knexInstance = knex(config);
    return knexInstance.schema.hasTable(config.migrations.tableName).then(function(exists) {
      if(exists) {
        return knexInstance.select('*').from(config.migrations.tableName).orderBy('id')
      } else {
        return []
      }
    }).then(function(completed) {
      return [knexInstance.migrate._listAll(), completed]
    })
  });

}

module.exports = status;
