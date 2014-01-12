sets = require('simplesets')
SchemaMigration = require('./schema_migration')
MigrationPath = require('./migration_path')
MigrationRunner = require('./migration_runner')
ourAdapter = require('./adapter')
_ = require('lodash')
Promise = require('bluebird')

#This is a replica of https://github.com/rails/docrails/blob/master/activerecord/lib/active_record/migration.rb#L764
class Migrator
  constructor: (@adapter, @direction, @_migrations, @targetVersion=null)->
    #TODO: Make sure the adapter supports migrations
    @validate(@_migrations)
    
  validate: (migrations)->
    #TODO: 
    #name ,= migrations.group_by(&:name).find { |_,v| v.length > 1 }
    #raise DuplicateMigrationNameError.new(name) if name

    #version ,= migrations.group_by(&:version).find { |_,v| v.length > 1 }
    #raise DuplicateMigrationVersionError.new(version) if version

  @migrate: (adapter, migrationsPaths, targetVersion, cb)-> 
    if !targetVersion
      @up(adapter, migrationsPaths, targetVersion, cb)
      #else if current_version == 0 && target_version == 0
      #[]
      #when current_version > target_version
      #down(migrations_paths, target_version, &block)
      #else
      #up(migrations_paths, target_version, &block)
      #end
      #switch targetVersion
      #when null

  @up: (adapter, migrationsPaths, targetVersion, cb)->
    MigrationPath.allMigrationFilesParsed(migrationsPaths, (err, migrations)->
      return cb(err) if err
      migrations_runners = _.map(migrations, (migration)-> new MigrationRunner(migration))
      migrator = new Migrator(adapter, 'up', migrations_runners, targetVersion)
      migrator.migrate(cb)
    )

  @currentVersion: ->
    #if Base.connection.table_exists?(sm_table)
      # get_all_versions.max || 0
      #else
      #0
      #end

  migrate: (cb)->
    if !@target() && @targetVersion && @targetVersion > 0
      return cb("Unknown migration version error #{targetVersion}")

    executeMigrationInTransaction = Promise.promisify(@executeMigrationInTransaction.bind(@))

    SchemaMigration.getAllVersions(@adapter, (err, versions)=>
      return cb(err) if err
      @migrated = new sets.Set(versions)
      promises = _.map(@runnable(), (migration)=>
        #TODO: Figure out how to do logging properly
        console.log "Migrating to #{migration.name()} (#{migration.version()})"
        executeMigrationInTransaction(migration, @direction)
        #rescue => e
        #canceled_msg = use_transaction?(migration) ? "this and " : ""
        #raise StandardError, "An error has occurred, #{canceled_msg}all later migrations canceled:\n\n#{e}", e.backtrace
        #end
      )

      Promise.all(promises).then(cb)
    )

  executeMigrationInTransaction: (migration, direction, cb)->
    @ddlTransaction(migration, =>
      migration.migrate(new ourAdapter(@adapter), direction, (err)=>
        @recordVersionStateAfterMigrating(migration.version())
        cb(err)
      )
    )

  recordVersionStateAfterMigrating: (version)->
    if @isDown()
      @migrated.remove(version)
      Promise.promisify(SchemaMigration.deleteAllByVersion(@adapter, version))
    else
      @migrated.add(version)
      Promise.promisify(SchemaMigration.create(@adapter, { version: version }))

  ddlTransaction: (migration, block)->
    #TODO: figure out how to use transactions
    block()

  migrations: ->
    clone = _.clone(@_migrations)
    if @isDown() then clone.reverse() else clone
      
  runnable: ->
    runnable = _(@migrations()[@start()..@finish()])
    if @isUp
      runnable.reject(@ran.bind(@)).value()
    else
      # skip the last migration if we're headed down, but not ALL the way down
      runnable.pop if target
      runnable.filter(@ran.bind(@)).value()

  start: ->
    0

  finish: ->
    @migrations().length-1
    
  isUp: ->
    @direction == 'up'

  isDown: ->
    @direction == 'down'

  ran: (migration)->
    _.contains(@migrated, migration.version())

  target: ->
    _.detect(@migrations(), (migration)=> migration.version() == @targetVersion)

module.exports = Migrator
