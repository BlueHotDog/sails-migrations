module.exports = {
  generate: require('./sails-migrations/generate.js'),
  migrate: require('./sails-migrations/migrate_to_latest.js'),
  rollback: require('./sails-migrations/rollback.js'),
  createDatabase: require('./sails-migrations/create_database.js'),
  dropDatabase: require('./sails-migrations/drop_database.js'),
  currentVersion: require('./sails-migrations/current_version.js'),
  status: require('./sails-migrations/status.js')
};