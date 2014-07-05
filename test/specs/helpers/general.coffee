path = require('path')
Promise = require('bluebird')
AdapterWrapper = rek('lib/sails-migrations/adapter_wrapper.coffee')
SchemaMigration = rek("lib/sails-migrations/schema_migration.coffee")
DatabaseTasks = rek('lib/sails-migrations/database_tasks.coffee')
SailsIntegration = rek('lib/sails-migrations/sails_integration.coffee')

class General
  @modulesPath: (version="")->path.resolve("samples/example_app#{version}/node_modules")
  @migrationsPath = (version="")->path.resolve("samples/example_app#{version}/db/migrations")

  @getAdapter: (version="")->
    resolver = Promise.defer()
    SailsIntegration.loadSailsConfig(@modulesPath(version), (err, config)=>
      return resolver.reject(err) if err
      resolver.resolve(config.defaultAdapter)
    )
    resolver.promise

  @getOurAdapter: ->
    @getAdapter().then((adapter)-> new AdapterWrapper(adapter))

  @recreateSchemaTable: (version="")->
    @getAdapter(version).then((adapter)->
      resolver = Promise.defer()
      SchemaMigration.drop(adapter, ->
        SchemaMigration.define(adapter, resolver.callback)
      )
      resolver.promise
    )

  @recreateDatabase: (version="")->
    resolver = Promise.defer()
    resetDb = (adapter)=>
      DatabaseTasks.dropSchema(adapter, =>
        DatabaseTasks.create(adapter, resolver.callback)
      )

    @getAdapter(version).then(resetDb)
    resolver.promise


module.exports = General
