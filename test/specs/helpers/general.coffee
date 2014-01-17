path = require('path')
Promise = require('bluebird')
SailsIntegration = rek("lib/sails-migrations/sails_integration.coffee")
AdapterWrapper = rek("lib/sails-migrations/adapter_wrapper.coffee")
SchemaMigration = rek("lib/sails-migrations/schema_migration.coffee")
DatabaseTasks = rek('lib/sails-migrations/database_tasks.coffee')

class General
  @modulesPath: path.resolve("test/example_app/node_modules")
  @migrationsPath = path.resolve('test/example_app/db/migrations')

  @getAdapter: ->
    resolver = Promise.defer()
    SailsIntegration.loadSailsConfig(@modulesPath, (err, config)=>
      return resolver.reject(err) if err
      resolver.resolve(config.defaultAdapter)
    )
    resolver.promise

  @getOurAdapter: ->
    @getAdapter().then((adapter)-> new AdapterWrapper(adapter))

  @recreateSchemaTable: ->
    @getAdapter().then((adapter)->
      resolver = Promise.defer()
      SchemaMigration.drop(adapter, ->
        SchemaMigration.define(adapter, resolver.callback)
      )
      resolver.promise
    )

  @recreateDatabase: ->
    resolver = Promise.defer()
    resetDb = (adapter)=>
      DatabaseTasks.drop(adapter, =>
        DatabaseTasks.create(adapter, resolver.callback)
      )

    @getAdapter().done(resetDb)
    resolver.promise


module.exports = General
