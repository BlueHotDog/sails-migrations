path = require('path')

class SailsIntegration
  cache = null;

  @loadSailsConfig: (modulesPath, cb)->
    return cb(null, cache) if cache
    options =
      globals: false
      loadHooks: ['moduleloader', 'userconfig', 'orm']
      appPath: path.join(modulesPath, "..")

    sailsPath = path.join(modulesPath, 'sails')
    sails = require(sailsPath)

    sails.load(options, (err)->
      return cb(err) if err

      defaultAdapterName =  sails.config.adapters.default
      dbConfig = sails.config.adapters[defaultAdapterName]

      adapter = require(path.join(modulesPath, dbConfig.module))
      adapter.config = dbConfig

      config =
        migrationLibPath: __dirname
        defaultAdapterName: defaultAdapterName
        defaultAdapter: adapter
        sailsPath: sailsPath
      cache = config;
      return cb(null, config)
    )

module.exports = SailsIntegration
