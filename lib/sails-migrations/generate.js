var migratorLoader = require('./helpers/migrator_loader.js');

function getMigrationName(name) {
  return name.replace(/( )/g, '_') || 'unnamed_migration';
}

function generateMigration(name, options) {
  name = getMigrationName(name);
  return migratorLoader.load().then(function(migrator) {
    return migrator.make(name, options)
  })
}


module.exports = generateMigration;