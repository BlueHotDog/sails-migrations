fs = require('fs')
path = require('path')
_ = require('lodash')
Migration = require('../../lib/sails-migrations/migration')
cleanupMigrationFiles = ->
  migrationPath = path.join(__dirname, 'example_app', 'db', 'migrations')
  console.log 'deleting files', migrationPath
  _.each(Migration.allMigrationsFiles(migrationPath), (file)->
    console.log 'deleting file', file
    fs.unlinkSync(file)
  )

describe 'migration:migrate', ->
  beforeEach ->
    cleanupMigrationFiles()

  it 'should run no migrations for 0 migrations', (done)->
    console.log 'aaa'
    done()

