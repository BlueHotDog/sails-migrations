migrationHelper = require('./migration_path')
_ = require('lodash')
SchemaMigration = require('./schema_migration')
MigrationPath = require('./migration_path')
Adapter = require('./adapter')

class MigrationRunner
  constructor: (@migrationData)->

  up: (adapter, cb)->
    migration = @requireMigration()

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

  version: ->
    @migrationData.version

  name: ->
    @migrationData.name

  path: ->
    @migrationData.path

  migrate: (adapter, direction, cb)->
    @[direction](adapter, cb)

  @migrate: (adapter, cb)->
    ourAdapter = new Adapter(adapter)
    MigrationPath.allMigrationFilesParsed(MigrationPath.migrationsPaths(), (err, migrations)->
      if _.isEmpty(migrations)
        cb(null, [])
      else
        _.each(migrations, (migration)->
          runner = new MigrationRunner(migration)
          runner.up(ourAdapter, cb)
        )
    )

module.exports = MigrationRunner
