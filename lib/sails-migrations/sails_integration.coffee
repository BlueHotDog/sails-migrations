path = require('path')

class SailsIntegration
  @loadSailsConfig: (modulesPath, cb)->
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

      return cb(null, config)
    )

module.exports = SailsIntegration
