var migratorLoader = require('./helpers/migrator_loader.js');
var fs = require('fs');
var path = require('path');
var errors = require('./errors');

function latest() {
  return migratorLoader.load().then(function(migrator) {
    var dbDir = path.resolve(migrator.config.directory);
    if (fs.existsSync(dbDir)) {
      return migrator.latest()
    } else {
      throw new errors.MigrationsFolderDoesNotExists(dbDir + " does not exists", migrator.config);
    }
  })

}
module.exports = latest;