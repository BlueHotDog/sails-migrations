fs = require('fs')
glob = require('glob')
_ = require('lodash')
sinon = require('sinon')
path = require('path')
assert = require('assert')

MigrationPath = rek('lib/sails-migrations/migration_path.coffee')
DatabaseTasks = rek('lib/sails-migrations/database_tasks.coffee')
Migrator = rek("lib/sails-migrations/migrator.coffee")
SchemaMigration = rek("lib/sails-migrations/schema_migration.coffee")
SailsIntegration = rek("lib/sails-migrations/sails_integration.coffee")
ourAdapter = rek("lib/sails-migrations/adapter.coffee")
migrationsPath = path.resolve('test/example_app/db/migrations')

cleanupMigrationFiles = (migrationsPath, cb)->
  MigrationPath.allMigrationsFiles(migrationsPath, (err, files)->
    _.each(files, fs.unlinkSync.bind(fs))
    cb()
  )

copyFixturesToMigrationsPath = ->
  fixturePath = path.resolve('test/specs/fixtures')
  migrationFixtures = glob.sync("#{fixturePath}/*.js", {})
  _.each(migrationFixtures, (file)->
    outputPath = "#{migrationsPath}/#{path.basename(file)}"
    fs.writeFileSync(outputPath, fs.readFileSync(file)) #copying
  )

describe 'db:migrate', ->
  beforeEach (done)->
    modulesPath = path.resolve("test/example_app/node_modules")
    SailsIntegration.loadSailsConfig(modulesPath, (err, config)=>
      @config = config
      @adapter = @config.defaultAdapter
      cleanupMigrationFiles(migrationsPath, ->
        done()
      )
    )

  beforeEach (done)->
    DatabaseTasks.drop(@adapter, (err)=>
      DatabaseTasks.create(@adapter, done)
    )

  beforeEach (done)->
    SchemaMigration.getInstance(@adapter, (err, Model)=>
      return done(err) if err
      Model.define(@adapter, done)
    )

  it 'should run 1 migrations for 1 migration files', (done)->
    copyFixturesToMigrationsPath()
    Migrator.migrate(@adapter, migrationsPath, null, (errors)->
      #TODO: We need to resolve the errors properly
      done()
    )

  afterEach (done)->
    new ourAdapter(@adapter).drop(SchemaMigration::tableName, done)
