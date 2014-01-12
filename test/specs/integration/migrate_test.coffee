fs = require('fs')
glob = require('glob')
_ = require('lodash')
sinon = require('sinon')
path = require('path')
assert = require('assert')

MigrationPath = rek('lib/sails-migrations/migration_path')
MigrationRunner = rek("lib/sails-migrations/migration_runner.coffee")
SailsIntegration = rek("lib/sails-migrations/sails_integration.coffee")
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

describe 'migration:migrate', ->
  beforeEach (done)->
    modulesPath = path.resolve("test/example_app/node_modules")
    SailsIntegration.loadSailsConfig(modulesPath, (err, config)=>
      @config = config
      @adapter = @config.defaultAdapter
      sinon.stub(MigrationPath, 'migrationsPaths', (-> [migrationsPath]))
      cleanupMigrationFiles(migrationsPath, ->
        done()
      )
    )

  it 'should run 1 migrations for 1 migration files', (done)->
    copyFixturesToMigrationsPath()
    MigrationRunner.migrate(@adapter, ->
      done()
    )
