migrationHelper = require('./migration')
SchemaMigration = require('./schema_migration')

class MigrationRunner
  constructor: (@migrationData)->

  up: (adapter, cb)->
    migration = @requireMigration()
    options = {adapters:{}}
    options.adapters["adapterName"] = adapter

    migration.up(adapter, (err)=>
      return cb(err) if err

      SchemaMigration.getInstance(adapter, (err, Model)=>
        Model.create({version: @migrationData.version}, (err, model)->
          return cb(err) if err
          cb(null, model)
        )
      )
    )

  down: (adapter, cb)->
    migration.down(cb)

  requireMigration: ->
    require(@migrationData.path)

module.exports = MigrationRunner
