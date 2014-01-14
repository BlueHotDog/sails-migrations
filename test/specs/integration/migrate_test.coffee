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

cleanupMigrationFiles = (migrationsPath)->
  rmdirp.sync(migrationsPath)

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

describe 'migration', ->
  before (done)->
    GeneralHelper.recreateDatabase().done((adapter)=>
      @adapter = adapter
      @AdapterWrapper = new AdapterWrapper(adapter)
      done()
    )

  # loading sails and reset the migrations folder
  beforeEach ->
    cleanupMigrationFiles(migrationsPath)

  # create the schem migrations folder
  beforeEach (done)->
    GeneralHelper.recreateSchemaTable().done(->done())

  describe 'db:migrate', ->
    it 'should be able to run a migration', (done)->
      tableName = 'one_migration'
      copyFixturesToMigrationsPath(tableName)
      Migrator.migrate(@adapter, migrationsPath, null, (err)=>
        return done(err) if err
        @AdapterWrapper.describe(tableName, (err, definition)->
          return done(err) if err
          assert.equal(_.keys(definition).length, 3)
          done()
        )
      )

    it 'should be able to run 2 migrations', (done)->
      tableName = 'two_migrations'
      copyFixturesToMigrationsPath(tableName)
      Migrator.migrate(@adapter, migrationsPath, null, (err)=>
        return done(err) if err
        @AdapterWrapper.describe(tableName, (err, definition)->
          return done(err) if err
          assert.equal(_.keys(definition).length, 4)
          done()
        )
      )

  describe 'db:rollback', ->
    it 'should rollback one migration', (done)->
      done()
      #Migrator.rollback

