fs = require('fs')
glob = require('glob')
_ = require('lodash')
sinon = require('sinon')
path = require('path')
assert = require('assert')

Migration = rek('lib/sails-migrations/migration')
DatabaseTasks = rek("lib/sails-migrations/database_tasks.coffee")
SailsIntegration = rek("lib/sails-migrations/sails_integration.coffee")
migrationsPath = path.resolve('test/example_app/db/migrations')

cleanupMigrationFiles = (migrationsPath, cb)->
  Migration.allMigrationsFiles(migrationsPath, (err, files)->
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
      sinon.stub(DatabaseTasks, 'migrationsPath', (-> migrationsPath))
      cleanupMigrationFiles(migrationsPath, ->
        done()
      )
    )

  it 'should run 1 migrations for 1 migration files', (done)->
    copyFixturesToMigrationsPath()
    DatabaseTasks.migrate(@adapter, ->
      done()
    )
