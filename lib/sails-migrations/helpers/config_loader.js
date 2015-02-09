const path = require('path');
const url = require('url');
const _ = require('lodash');
const Promise = require('bluebird');
const SailsIntegration = require('./sails_integration');

const sailsToKnexClient = {
  'sails-postgresql': 'pg',
  'sails-mysql': 'mysql'
};

function getModulesPath(basePath) {
  const baseAppPath = basePath || process.cwd();
  return path.join(baseAppPath, 'node_modules');
}

function getClientFromSailsConfig(sailsConfig) {
  var adapter;
  switch(sailsConfig.defaultAdapter.version) {
    case '0.10':
      adapter = sailsConfig.defaultAdapter.config.adapter;
      break;
    case '0.9':
      adapter = sailsConfig.defaultAdapter.identity;
      break;
  }
  return sailsToKnexClient[adapter];
}

function getConfigFromSailsConfig(sailsConfig) {
  const connection = getConnectionFromSailsConfig(sailsConfig)

  const client = getClientFromSailsConfig(sailsConfig);

  const migrations = {
    tableName: 'sails_migrations',
    directory: './db/migrations'
  };

  return {
    client: client,
    connection: connection,
    migrations: migrations
  };
}

function getConnectionFromSailsConfig(sailsConfig) {
  if (typeof sailsConfig.defaultAdapter.config.url !== 'undefined' && sailsConfig.defaultAdapter.config.url !== null) {
    var dbUrl = url.parse(sailsConfig.defaultAdapter.config.url);
    return {
      host: dbUrl.hostname,
      user: dbUrl.auth.split(':')[0],
      port: dbUrl.port,
      database: dbUrl.path.slice(1),
      password: dbUrl.auth.split(':')[1]
    }
  } else {
    const fullConfig = _.defaults({}, sailsConfig.defaultAdapter.config, sailsConfig.defaultAdapter.defaults);
    return {
      host: fullConfig.host,
      user: fullConfig.user,
      port: fullConfig.port,
      database: fullConfig.database,
      password: fullConfig.password,
      ssl: fullConfig.ssl || false
    };
  }
}

function getConfig(basePath) {
  const modulesPath = getModulesPath(basePath);

  return Promise.promisify(SailsIntegration.loadSailsConfig)(modulesPath).then(getConfigFromSailsConfig);
}


exports.load = getConfig;
