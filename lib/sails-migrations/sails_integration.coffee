path = require('path')

class SailsIntegration
  @loadSailsConfig: (sails, adapterLoadPath, cb)->
    options =
      globals: false
      loadHooks: ['moduleloader', 'userconfig', 'orm']

    sails.load(options, (err)->
      return cb(err) if err

      defaultAdapterName =  sails.config.adapters.default
      dbConfig = sails.config.adapters[defaultAdapterName]
      adapter = require(path.join(adapterLoadPath, dbConfig.module))
      adapter.config = dbConfig

      config =
        migrationLibPath: __dirname
        defaultAdapterName: defaultAdapterName
        defaultAdapter: adapter
      cb(null, config)
    )

module.exports = SailsIntegration
