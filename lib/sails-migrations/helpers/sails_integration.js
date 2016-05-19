const path = require('path');
const _ = require('lodash');

function getSailsVersion(sailsObject) {
  var version = sailsObject.version;
  if (sailsObject.config.adapters) {
    return "0.9";
  } else {
    // get the minor version
    return version.split('.').splice(0, 2).join('.');
  }
}


function SailsIntegration() {
}

var cache = null;

sailsPath = function (modulesPath) {
  return path.join(modulesPath, 'sails');
};

SailsIntegration.loadSailsConfig = function (modulesPath, cb) {
  var options, sails;

  if (cache) { return cb(null, cache); }

  options = {
    globals:   false,
    loadHooks: ['moduleloader', 'userconfig'],
    appPath:   path.join(modulesPath, "..")
  };

  sails = require(sailsPath(modulesPath));
  return sails.load(options, function (err) {
    if (err) { return cb(err); }
    cache = SailsIntegration.getSailsConfig(modulesPath, sails);
    return cb(null, cache);
  });
};

SailsIntegration.getSailsConfig = function (modulesPath, sails) {
  var adapter, dbConfig, defaultAdapterName, moduleName;
  const sailsVersion = getSailsVersion(sails);
  switch (true) {
    case sailsVersion === "0.9":
      defaultAdapterName = sails.config.adapters["default"];
      dbConfig = sails.config.adapters[defaultAdapterName];
      moduleName = dbConfig.module;
      break;
    case _.contains(["0.10", "0.11", "0.12"], sailsVersion):
      defaultAdapterName = sails.config.models.connection;
      dbConfig = sails.config.connections[defaultAdapterName];
      moduleName = dbConfig.adapter;
  }
  adapter = require(path.join(modulesPath, moduleName));
  adapter.config = dbConfig;
  adapter.version = sailsVersion;

  return {
    migrationLibPath:   __dirname,
    defaultAdapterName: defaultAdapterName,
    defaultAdapter:     adapter,
    sailsPath:          sailsPath(modulesPath)
  };
};


module.exports = SailsIntegration;
