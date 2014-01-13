class MigrationRunner
  constructor: (@migrationData)->

  up: (adapter, cb)->
    migration = @requireMigration()

    migration.up(adapter, cb)

  down: (adapter, cb)->
    migration = @requireMigration()

    migration.down(adapter, cb)

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

module.exports = MigrationRunner
