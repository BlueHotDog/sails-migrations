/**
 * Global adapter config
 * 
 * The `adapters` configuration object lets you create different global "saved settings"
 * that you can mix and match in your models.  The `default` option indicates which 
 * "saved setting" should be used if a model doesn't have an adapter specified.
 *
 * Keep in mind that options you define directly in your model definitions
 * will override these settings.
 *
 * For more information on adapter configuration, check out:
 * http://sailsjs.org/#documentation
 */

module.exports.adapters = {

  // If you leave the adapter config unspecified 
  // in a model definition, 'default' will be used.
  'default': process.env.SAILS_ADAPTER_NAME || 'postgresql',

  // Persistent adapter for DEVELOPMENT ONLY
  // (data is preserved when the server shuts down)
  disk: {
    module: 'sails-disk'
  },

  mysql: {
    module: 'sails-mysql',
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: '',
    database: 'sails_migrations_test_098'
  },
  postgresql: {
    module: 'sails-postgresql',
    host: process.env.DBPOSTGRES_PORT_5432_TCP_ADDR || 'localhost',
    port: process.env.DBPOSTGRES_PORT_5432_TCP_PORT || 5432,
    user: process.env.USERNAME,
    password: process.env.PASSWORD,
    database: 'sails_migrations_test_0_9_8'
  }
};
