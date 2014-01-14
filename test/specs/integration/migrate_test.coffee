fs = require('fs')
glob = require('glob')
path = require('path')
assert = require('assert')
mkdirp = require('mkdirp')
rmdirp = require('../helpers/rmdirp.coffee')
GeneralHelper = require("../helpers/general.coffee")

MigrationPath = rek('lib/sails-migrations/migration_path.coffee')
Migrator = rek("lib/sails-migrations/migrator.coffee")
SchemaMigration = rek("lib/sails-migrations/schema_migration.coffee")
SailsIntegration = rek("lib/sails-migrations/sails_integration.coffee")
AdapterWrapper = rek("lib/sails-migrations/adapter_wrapper.coffee")
migrationsPath = path.resolve('test/example_app/db/migrations')

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

migrateScope = (adapter, migrationsPath, scope, cb)->
  copyFixturesToMigrationsPath(scope)
  Migrator.migrate(adapter, migrationsPath, null, cb)

assertTableColumnCount = (adapterWrapper, tableName, expectedColumns, cb)->
  adapterWrapper.describe(tableName, (err, definition)->
    return cb(err) if err
    assert.equal(_.keys(definition).length, expectedColumns)
    cb()
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

  # create the schem migrations folder
  beforeEach (done)->
    GeneralHelper.recreateSchemaTable().done(->done())

  describe 'db:migrate', ->
    it 'should be able to run a migration', (done)->
      tableName = 'one_migration'
      migrateScope(@adapter, migrationsPath, tableName, (err)=>
        return done(err) if err
        assertTableColumnCount(@AdapterWrapper, tableName, 3, done)
      )

    it 'should be able to run 2 migrations', (done)->
      tableName = 'two_migrations'
      migrateScope(@adapter, migrationsPath, tableName, (err)=>
        return done(err) if err
        assertTableColumnCount(@AdapterWrapper, tableName, 4, done)
      )

  describe 'db:rollback', ->
    it 'should rollback one migration', (done)->
      Migrator.rollback(@adapter, migrationsPath, null, (err)=>
        done(err)
      )
