path = require('path')
Promise = require('bluebird')
SailsIntegration = rek("lib/sails-migrations/sails_integration.coffee")
OurAdapter = rek("lib/sails-migrations/adapter.coffee")
SchemaMigration = rek("lib/sails-migrations/schema_migration.coffee")

class General
  @modulesPath: path.resolve("test/example_app/node_modules")

  @getOurAdapter: ->
    resolver = Promise.defer()
    SailsIntegration.loadSailsConfig(@modulesPath, (err, config)=>
      adapter = config.defaultAdapter
      ourAdapter = new OurAdapter(adapter)
      resolver.resolve(ourAdapter)
    )
    resolver.promise

  @recreateTable: (tableName, attributes)->
    resolver = Promise.defer()
    @getOurAdapter().then((adapter)->
      adapter.drop(tableName, (err) ->
        return resolver.reject(err) if err
        adapter.define(tableName, attributes, resolver.callback)
      )
    )
    resolver.promise

  @recreateSchemaTable: ->
    @recreateTable(SchemaMigration::tableName, SchemaMigration::attributes)


module.exports = General;
