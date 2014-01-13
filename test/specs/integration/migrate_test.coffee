fs = require('fs')
glob = require('glob')
_ = require('lodash')
sinon = require('sinon')
path = require('path')
assert = require('assert')
mkdirp = require('mkdirp')
rmdirp = require('../helpers/rmdirp.coffee')

MigrationPath = rek('lib/sails-migrations/migration_path.coffee')
DatabaseTasks = rek('lib/sails-migrations/database_tasks.coffee')
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
    modulesPath = path.resolve("test/example_app/node_modules")
    SailsIntegration.loadSailsConfig(modulesPath, (err, config)=>
      @config = config
      @adapter = @config.defaultAdapter
      @AdapterWrapper = new AdapterWrapper(@adapter)

      DatabaseTasks.drop(@adapter, (err)=>
#        console.log("err", err)
        DatabaseTasks.create(@adapter, (err)=>
#          console.log("err2", err)
          done(err)
        )
      )
    )

  # loading sails and reset the migrations folder
  beforeEach ->
    cleanupMigrationFiles(migrationsPath)


  # create the schem migrations folder
  beforeEach (done)->
    @AdapterWrapper.drop(SchemaMigration::tableName, (err)=>
      return done(err) if err
      @AdapterWrapper.define(SchemaMigration::tableName, SchemaMigration::attributes, done)
    )

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
      Migrator.rollback

