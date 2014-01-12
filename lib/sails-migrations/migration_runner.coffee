migrationHelper = require('./migration')
_ = require('lodash')
SchemaMigration = require('./schema_migration')
Migration = require('./migration')

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

  @migrate: (adapter, cb)->
    Migration.allMigrationFilesParsed(Migration.migrationsPaths(), (err, migrations)->
      if _.isEmpty(migrations)
        cb(null, [])
      else
        _.each(migrations, (migration)->
          runner = new MigrationRunner(migration)
          runner.up(adapter, cb)
        )
    )

module.exports = MigrationRunner
