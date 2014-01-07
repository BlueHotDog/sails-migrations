path = require('path')

class SailsIntegration
  @loadSailsConfig: (sails, cb)->
    options =
      globals: false
      loadHooks: ['moduleloader', 'userconfig', 'orm']

    sails.load(options, (err)->
      return cb(err) if err

      defaultAdapterName =  sails.config.adapters.default
      dbConfig = sails.config.adapters[defaultAdapterName]
      adapter = require(path.join(basePath, "test/test_app/node_modules", dbConfig.module))
      adapter.config = dbConfig

      config =
        migrationLibPath: __dirname
        defaultAdapterName: defaultAdapterName
        defaultAdapter: adapter
      cb(config)
    )

module.exports = SailsIntegration
