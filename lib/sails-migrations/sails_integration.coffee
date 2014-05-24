path = require('path')

class SailsIntegration
  cache= null

  sailsPath = (modulesPath) ->
    path.join(modulesPath, 'sails')

  @loadSailsConfig: (modulesPath, cb)->
    return cb(null, cache) if cache
    options =
      globals: false
      loadHooks: ['moduleloader', 'userconfig', 'orm']
      appPath: path.join(modulesPath, "..")

    sails = require(sailsPath(modulesPath))
    sails.load(options, (err)=>
      return cb(err) if err
      cache = @getSailsConfig(modulesPath, sails);
      return cb(null, cache)
    )

  @getSailsConfig: (modulesPath, sails)->
    defaultAdapterName =  sails.config.models.connection
    dbConfig = sails.config.connections[defaultAdapterName]
    moduleName = dbConfig.adapter


    adapter = require(path.join(modulesPath, moduleName))
    adapter.config = dbConfig

    {
      migrationLibPath: __dirname
      defaultAdapterName: defaultAdapterName
      defaultAdapter: adapter
      sailsPath: sailsPath(modulesPath)
    }

module.exports = SailsIntegration
