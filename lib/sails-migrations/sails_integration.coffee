path = require('path')
_ = require('lodash')

getSailsVersion = (sailsObject)->
  if sailsObject.config.adapters
    "0.9"
  else
    "0.10"

class SailsIntegration
  cache = null

  sailsPath = (modulesPath) ->
    path.join(modulesPath, 'sails')

  @loadSailsConfig: (modulesPath, withModels, cb)->
    return cb(null, cache) if cache

    options =
      globals: false
      loadHooks: ['moduleloader', 'userconfig', 'orm']
      appPath: path.join(modulesPath, "..")

    options.paths = models: path.join(__dirname, 'models') if withModels

    sails = new require(sailsPath(modulesPath)).Sails()
    sails.load(options, (err)=>
      return cb(err) if err
      cache = @getSailsConfig(modulesPath, sails)
      cb(null, cache)
    )

  @getSailsConfig: (modulesPath, sails)->
    switch getSailsVersion(sails)
      when "0.9"
        defaultAdapterName =  sails.config.adapters.default
        dbConfig = sails.config.adapters[defaultAdapterName]
        moduleName = dbConfig.module
      when "0.10"
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
      schema_migration: sails.models.schema_migration
    }

  @invalidateCache: ()->
    cache = null

module.exports = SailsIntegration
