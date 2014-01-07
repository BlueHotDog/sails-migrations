migrationHelper = require('./migration')

class MigrationRunner
  constructor: (@migrationFilename)->
    @metadata = migrationHelper.parseMigrationFileName(@migrationFilename)

  up: (cb)->
    migration = @requireMigration()
    console.log "#{@migrationFilename} before migration up"
    migration.up( (err)->
      return cb(err) if err
      cb()
    )

  down: (cb)->
    migration.down(cb)

  requireMigration: ->
    require(@migrationFilename)
