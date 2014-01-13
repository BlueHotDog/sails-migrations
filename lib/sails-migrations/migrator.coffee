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
      @move('up', adapter, migrationsPaths, targetVersion, cb)
    else 
      @currentVersion( (err, currentVersion)=>
        return cb(err) if err
        if currentVersion == 0 && targetVersion == 0
          cb(null, [])
        else if currentVersion > targetVersion
          @move('down', adapter, migrationsPaths, targetVersion, cb)
        else
          @move('up', migrationsPaths, targetVersion, cb)
      )

  @rollback: (adapter, migrationsPaths, steps, cb)->
    @calculateTargetVersion(adapter, migrationsPaths, steps).then((version)=>
      console.log(version)
#      @migrate(adapter, migrationsPaths, version, cb)
    ).catch(cb)

  @move: (direction, adapter, migrationsPaths, targetVersion, cb)->
    MigrationPath.allMigrationFilesParsed(migrationsPaths, (err, migrations)->
      return cb(err) if err
      migrations_runners = _.map(migrations, (migration)-> new MigrationRunner(migration))
      migrator = new Migrator(adapter, direction, migrations_runners, targetVersion)
      migrator.migrate(cb)
    )

  @currentVersion: (cb)->
    SchemaMigration.getAllVersions(@adapter, (err, versions)=>
      return cb(err) if err
      maxVersion = _.max(versions) || 0
      cb(null, maxVersion)
    )

  @calculateTargetVersion: (adapter, migrationsPaths, steps)->
    allMigrationFilesPromise = Promise.Promisify(MigrationPath.allMigrationFilesParsed)(allMigrationFiles)
    currentVersionPromise = Promise.Promisify(@currentVersion)()
    Promise.settle([allMigrationFilesPromise, currentVersionPromise]).then((res)->
      console.log(res)
    )
    ###
migrator = self.new(direction, migrations(migrations_paths))
        start_index = migrator.migrations.index(migrator.current_migration)

        if start_index
          finish = migrator.migrations[start_index + steps]
          version = finish ? finish.version : 0
          send(direction, migrations_paths, version)
        end
###

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

      #TODO: We need to resolve the errors properly
      Promise.all(promises).then( (errors)->
        cb(null)
      )
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
