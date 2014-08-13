fs = require('fs')
glob = require('glob')
path = require('path')
assert = require('assert')
mkdirp = require('mkdirp')
rmdirp = require('../helpers/rmdirp.coffee')
GeneralHelper = require("../helpers/general.coffee")
CustomAssertions = require("../helpers/custom_assertions.coffee")
SchemaMigration = rek("lib/sails-migrations/models/schema_migration.coffee")

Migrator = rek("lib/sails-migrations/migrator.coffee")
AdapterWrapper = rek("lib/sails-migrations/adapter_wrapper.coffee")

copy = (files, outputPath)->
  _.each(files, (file)->
    p = "#{outputPath}/#{path.basename(file)}"
    fs.writeFileSync(p, fs.readFileSync(file)) #copying
  )

copyFixturesToMigrationsPath = (scope, migrationsPath)->
  mkdirp.sync(migrationsPath) #This should create the db/migrations + db/migrations/definitions dirs in the example_app
  fixturePath = path.resolve('test/specs/fixtures/migrations')
  migrationFixtures = glob.sync("#{fixturePath}/*#{scope}*.js", {})
  copy(migrationFixtures, migrationsPath)

# Runs migration on the migration files that include provided name (scope)
migrateScope = (adapter, migrationsPath, scope, targetVersion, cb)->
  copyFixturesToMigrationsPath(scope, migrationsPath)
  Migrator.migrate(adapter, migrationsPath, targetVersion, (err)=>
    return cb(err) if err
    SchemaMigration.getAllVersions(adapter, cb)
  )

# Runs all the migrations as the default behavior is without a targetVersion
migrateScopeDefault = (adapter, migrationsPath, scope, cb)->
  migrateScope(adapter, migrationsPath, scope, null, cb)

# Runs rollback on the migration files that include provided name (scope)
rollbackScope = (adapter, migrationsPath, scope, steps, withMigrate, cb)->
  if withMigrate
    migrateScopeDefault(adapter, migrationsPath, scope, (err)=>
      return cb(err) if err
      Migrator.rollback(adapter, migrationsPath, steps, (err)=>
        return cb(err) if err
        SchemaMigration.getAllVersions(adapter, cb)
      )
    )
  else
    Migrator.rollback(adapter, migrationsPath, steps, (err)=>
      return cb(err) if err
      SchemaMigration.getAllVersions(adapter, cb)
    )

# Runs rollback with the default behavior which is when given no steps (null) then the migrator
# will rollback to the previous version
rollbackScopeDefault = (adapter, migrationsPath, scope, withMigrate, cb)->
  rollbackScope(adapter, migrationsPath, scope, null, withMigrate, cb)

version = process.env.SAILS_VERSION
migrationsPath = GeneralHelper.migrationsPath(version)
describe "integration for version #{version}", ->
  describe 'migration', ->
    beforeEach (done)->
      # reset the migrations folder
      rmdirp.sync(migrationsPath)
      temp = GeneralHelper.recreateDatabase(version)
      temp.then((adapter)=>
        @adapter = adapter
        @AdapterWrapper = new AdapterWrapper(adapter)
        GeneralHelper.recreateSchemaTable(version).then(->done())
      )

    describe 'db:migrate', ->
      context 'default behavior', ->
        it 'should be able to run a migration', (done)->
          @tableName = 'one_migration'
          migrateScopeDefault(@adapter, migrationsPath, @tableName, (err, versions)=>
            return done(err) if err
            assert.equal(versions.length, 1)
            CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 3, done)
          )

        it 'should be able to run 2 migrations', (done)->
          @tableName = 'two_migrations'
          migrateScopeDefault(@adapter, migrationsPath, @tableName, (err, versions)=>
            return done(err) if err
            assert.equal(versions.length, 2)
            CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 4, done)
          )

        it 'should be able to run many migrations', (done)->
          @tableName = 'many_migrations'
          migrateScopeDefault(@adapter, migrationsPath, @tableName, (err, versions)=>
            return done(err) if err
            assert.equal(versions.length, 5)
            CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 3, done)
          )

      context 'when a valid targetVersion is given', ->
        it 'should be able to run 1 migrations correctly', (done)->
          @tableName = 'many_migrations'
          migrateScope(@adapter, migrationsPath, @tableName, 20141, (err, versions)=>
            return done(err) if err
            assert.equal(versions.length, 1)
            CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 3, done)
          )

        it 'should be able to run 2 migrations correctly', (done)->
          @tableName = 'many_migrations'
          migrateScope(@adapter, migrationsPath, @tableName, 20142, (err, versions)=>
            return done(err) if err
            assert.equal(versions.length, 2)
            CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 4, done)
          )

        it 'should be able to run 4 migrations correctly', (done)->
          @tableName = 'many_migrations'
          migrateScope(@adapter, migrationsPath, @tableName, 20144, (err, versions)=>
            return done(err) if err
            assert.equal(versions.length, 4)
            CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 2, done)
          )

        it 'should be able to run migrate to a targetVersion and then run again until the end', (done)->
          @tableName = 'many_migrations'
          migrateScope(@adapter, migrationsPath, @tableName, 20142, (err, versions)=>
            return done(err) if err
            migrateScope(@adapter, migrationsPath, @tableName, null, (err, versions)=>
              return done(err) if err

              assert.equal(versions.length, 5)
              CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 3, done)
            )
          )

      context 'when an invalid targetVersion is given', ->
        it 'should throw an error', (done)->
          @tableName = 'many_migrations'
          migrateScope(@adapter, migrationsPath, @tableName, 2220141, (err, versions)=>
            assert.equal(err, 'Unknown migration version error 2220141')
            done()
          )

    describe 'db:rollback', ->
      context 'default behavior', ->
        it 'should be able rollback one migration', (done)->
          @tableName = 'one_migration'
          rollbackScopeDefault(@adapter, migrationsPath, @tableName, true, (err, versions)=>
            return done(err) if err
            assert.equal(versions.length, 0)
            CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 0, done)
          )

        it 'should be able to rollback once with two migrations', (done)->
          @tableName = 'two_migrations'
          rollbackScopeDefault(@adapter, migrationsPath, @tableName, true, (err, versions)=>
            return done(err) if err
            assert.equal(versions.length, 1)
            CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 3, done)
          )

        it 'should be able rollback once with many migrations', (done)->
          @tableName = 'many_migrations'
          rollbackScopeDefault(@adapter, migrationsPath, @tableName, true, (err, versions)=>
            return done(err) if err
            assert.equal(versions.length, 4)
            CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 2, done)
          )

        it 'should be able to rollback twice correctly', (done)->
          @tableName = 'many_migrations'
          rollbackScopeDefault(@adapter, migrationsPath, @tableName, true, (err, versions)=>
            return done(err) if err
            rollbackScopeDefault(@adapter, migrationsPath, @tableName, false, (e, vers)=>
              return done(err) if err
              assert.equal(vers.length, 3)
              CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 3, done)
            )
          )

      context 'when a valid steps argument is given', ->
        it 'should be able rollback two steps', (done)->
          @tableName = 'many_migrations'
          rollbackScope(@adapter, migrationsPath, @tableName, 2, true, (err, versions)=>
            return done(err) if err
            assert.equal(versions.length, 3)
            CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 3, done)
          )

        it 'should be able rollback many steps', (done)->
          @tableName = 'many_migrations'
          rollbackScope(@adapter, migrationsPath, @tableName, 4, true, (err, versions)=>
            return done(err) if err
            assert.equal(versions.length, 1)
            CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 3, done)
          )
