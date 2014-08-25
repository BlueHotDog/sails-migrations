path = require('path')
_ = require('lodash')
Promise = require('bluebird')

getSailsVersion = (sailsObject)->
  if sailsObject.config.adapters
    "0.9"
  else
    "0.10"

class SailsIntegration
  cache = null

  sailsPath = (modulesPath) ->
    path.join(modulesPath, 'sails')

  waterlinePath = (modulesPath)->
    path.join(sailsPath(modulesPath), 'node_modules', 'waterline')

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

  #Since Sails doesn't allow us to access the waterline instance it uses,
  #this workaround is implemented to make sure all the open connections
  #by waterline are closed
  @unloadSails: (cb)->
    return cb(null) unless cache
    adapterNamesUnique = _.chain(cache.sails.config.connections)
      .map( (valueConn, connName)->
        connectionName: connName, adapter: cache.sails.adapters[valueConn.adapter]
      ).filter( (conn)->
        conn.adapter
      ).value()

    teardownAdapters = _.map(adapterNamesUnique, (connObj)->
      resolver = Promise.defer()
      adapter = connObj.adapter
      adapter.teardown(connObj.connectionName, resolver.callback)
      resolver.promise
    )

    Promise.all(teardownAdapters).then( (err)=>
      @invalidateCache()
      cb()
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

    adapter = @_loadAdapter(modulesPath, moduleName)
    adapter.config = dbConfig

    {
      migrationLibPath: __dirname
      defaultAdapterName: defaultAdapterName
      defaultAdapter: adapter
      sailsPath: sailsPath(modulesPath)
      schema_migration: sails.models.schema_migration
      sails: sails
    }

  @invalidateCache: ->
    cache = null

  @_loadAdapter: (modulesPath, moduleName)->
    require(path.join(modulesPath, moduleName))

  @_loadAllAdapters: ->

module.exports = SailsIntegration
