fs = require('fs')
glob = require('glob')
path = require('path')
assert = require('assert')
mkdirp = require('mkdirp')
rmdirp = require('../helpers/rmdirp.coffee')
GeneralHelper = require("../helpers/general.coffee")
CustomAssertions = require("../helpers/custom_assertions.coffee")
SchemaMigration = rek("lib/sails-migrations/schema_migration.coffee")

Migrator = rek("lib/sails-migrations/migrator.coffee")
AdapterWrapper = rek("lib/sails-migrations/adapter_wrapper.coffee")
migrationsPath = GeneralHelper.migrationsPath

copy = (files, outputPath)->
  _.each(files, (file)->
    p = "#{outputPath}/#{path.basename(file)}"
    fs.writeFileSync(p, fs.readFileSync(file)) #copying
  )

copyFixturesToMigrationsPath = (scope)->
  mkdirp.sync(migrationsPath) #This should create the db/migrations + db/migrations/definitions dirs in the example_app
  fixturePath = path.resolve('test/specs/fixtures/migrations')
  migrationFixtures = glob.sync("#{fixturePath}/*#{scope}*.js", {})
  copy(migrationFixtures, migrationsPath)

# Runs migration on the migration files that include provided name (scope)
migrateScope = (adapter, migrationsPath, scope, cb)->
  copyFixturesToMigrationsPath(scope)
  Migrator.migrate(adapter, migrationsPath, null, (err)=>
    return cb(err) if err
    SchemaMigration.getAllVersions(adapter, cb)
  )

# Runs rollback on the migration files that include provided name (scope)
rollbackScope = (adapter, migrationsPath, scope, cb)->
  migrateScope(adapter, migrationsPath, scope, (err)=>
    return cb(err) if err
    Migrator.rollback(adapter, migrationsPath, null, (err)=>
      return cb(err) if err
      SchemaMigration.getAllVersions(adapter, cb)
    )
  )

describe 'migration', ->
  # reset the database #TODO: move this to a pretest task?
  before (done)->
    GeneralHelper.recreateDatabase().done((adapter)=>
      @adapter = adapter
      @AdapterWrapper = new AdapterWrapper(adapter)
      done()
    )

  # reset the migrations folder
  beforeEach ->
    rmdirp.sync(migrationsPath)

  # create the schema migrations folder
  beforeEach (done)->
    GeneralHelper.recreateSchemaTable().done(->done())

  describe 'db:migrate', ->
    it 'should be able to run a migration', (done)->
      @tableName = 'one_migration'
      migrateScope(@adapter, migrationsPath, @tableName, (err, versions)=>
        return done(err) if err
        CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 3, done)
        assert.equal(versions.length, 1)
      )

    it 'should be able to run 2 migrations', (done)->
      @tableName = 'two_migrations'
      migrateScope(@adapter, migrationsPath, @tableName, (err, versions)=>
        return done(err) if err
        CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 4, done)
        assert.equal(versions.length, 2)
      )

  describe 'db:rollback', ->
    it 'should rollback one migration', (done)->
      @tableName = 'one_migration'
      rollbackScope(@adapter, migrationsPath, @tableName, (err, versions)=>
        return done(err) if err
        CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 0, done)
        assert.equal(versions.length, 0)
      )

    it 'should rollback once with two migrations', (done)->
      @tableName = 'two_migrations'
      rollbackScope(@adapter, migrationsPath, @tableName, (err, versions)=>
        return done(err) if err
        CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 3, done)
        assert.equal(versions.length, 1)
      )

  afterEach (done)->
    @AdapterWrapper.drop(@tableName, done)
