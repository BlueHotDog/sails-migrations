migrationHelper = require('./migration')
SchemaMigration = require('./schema_migration')

class MigrationRunner
  constructor: (@migrationFilename)->
    @metadata = migrationHelper.parseMigrationFileName(@migrationFilename)

  up: (adapter, cb)->
    migration = @requireMigration()
    console.log "#{@migrationFilename} before migration up"
    console.log adapter

    options = {adapters:{}}
    options.adapters[adapter.name] = adapter

    migration.up(adapter, (err)->
      return cb(err) if err
      sm = new SchemaMigration(adapter.name)(options, (err, Model)->
        Model.create({version: @metadata.version}, (err, model)->
          return cb(err) if err
          cb(null, model)
        )
      )
    )

  down: (adapter, cb)->
    migration.down(cb)

  requireMigration: ->
    require(@migrationFilename)

module.exports = MigrationRunner
