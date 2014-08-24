path = require('path')
errors = rek('lib/sails-migrations/errors')
Promise = require('bluebird')
AdapterWrapper = rek('lib/sails-migrations/adapter_wrapper.coffee')
DatabaseTasks = rek('lib/sails-migrations/database_tasks.coffee')
SailsIntegration = rek('lib/sails-migrations/sails_integration.coffee')

class General
  @modulesPath: (version="")->path.resolve("samples/example_app#{version}/node_modules")
  @migrationsPath = (version="")->path.resolve("samples/example_app#{version}/db/migrations")

  @getConfig: (version="", withModels = true)->
    resolver = Promise.defer()
    SailsIntegration.loadSailsConfig(@modulesPath(version), withModels, (err, config)=>
      return resolver.reject(err) if err
      resolver.resolve(config)
    )
    resolver.promise

  #Need to go through all the adapters that sails loaded and run teardown on them
  @teardown: (cb)->
    SailsIntegration.unloadSails(cb)

  @getOurAdapter: (version)->
    @getConfig(version).then((config)-> new AdapterWrapper(config.defaultAdapter))

  @getSchemaMigration: (version)->
    @getConfig(version).then((config)-> config.schema_migration)

  @recreateSchemaTable: (version="")->
    SailsIntegration.invalidateCache()
    @getConfig(version).then((config)->
      resolver = Promise.defer()
      SchemaMigration = config.schema_migration
      SchemaMigration.define(SchemaMigration.attributes, resolver.callback)
      resolver.promise
    )

  @recreateDatabase: (version="")->
    resolver = Promise.defer()
    dropSchema = Promise.promisify(DatabaseTasks.dropSchema.bind(DatabaseTasks))
    create = Promise.promisify(DatabaseTasks.create.bind(DatabaseTasks))
    resetDb = (adapter)=>
      dropSchema(adapter).then(create)

    @getConfig(version, false)
      .then((config)->
        resetDb(config.defaultAdapter)
      ).then((config)->
        resolver.resolve(config.defaultAdapter, config.schema_migration)
      ).catch(errors.DatabaseAlreadyExists, (err)->
        resolver.resolve(err.adapter)
      )
    resolver.promise


module.exports = General
