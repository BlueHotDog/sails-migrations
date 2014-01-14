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
migrateScope = (adapter, migrationsPath, scope, targetVersion, cb)->
  copyFixturesToMigrationsPath(scope)
  Migrator.migrate(adapter, migrationsPath, targetVersion, (err)=>
    return cb(err) if err
    SchemaMigration.getAllVersions(adapter, cb)
  )

# Runs all the migrations as the default behavior is without a targetVersion
migrateScopeDefault = (adapter, migrationsPath, scope, cb)->
  migrateScope(adapter, migrationsPath, scope, null, cb)

# Runs rollback on the migration files that include provided name (scope)
rollbackScope = (adapter, migrationsPath, scope, steps, cb)->
  migrateScopeDefault(adapter, migrationsPath, scope, (err)=>
    return cb(err) if err
    Migrator.rollback(adapter, migrationsPath, steps, (err)=>
      return cb(err) if err
      SchemaMigration.getAllVersions(adapter, cb)
    )
  )

# Runs rollback with the default behavior which is when given no steps (null) then the migrator
# will rollback to the previous version
rollbackScopeDefault = (adapter, migrationsPath, scope, cb)->
  rollbackScope(adapter, migrationsPath, scope, null, cb)

describe 'migration', ->
  # reset the migrations folder
  beforeEach ->
    rmdirp.sync(migrationsPath)

  beforeEach (done)->
    GeneralHelper.recreateDatabase().done((adapter)=>
      @adapter = adapter
      @AdapterWrapper = new AdapterWrapper(adapter)
      done()
    )

  # create the schema migrations folder
  beforeEach (done)->
    GeneralHelper.recreateSchemaTable().done(->done())

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

      it 'should be able to run migrations correctly', (done)->
        @tableName = 'many_migrations'
        migrateScope(@adapter, migrationsPath, @tableName, 20143, (err, versions)=>
          return done(err) if err
          assert.equal(versions.length, 3)
          CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 3, done)
        )

  describe 'db:rollback', ->
    context 'default behavior', ->
      it 'should be able rollback one migration', (done)->
        @tableName = 'one_migration'
        rollbackScopeDefault(@adapter, migrationsPath, @tableName, (err, versions)=>
          return done(err) if err
          assert.equal(versions.length, 0)
          CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 0, done)
        )

      it 'should be able to rollback once with two migrations', (done)->
        @tableName = 'two_migrations'
        rollbackScopeDefault(@adapter, migrationsPath, @tableName, (err, versions)=>
          return done(err) if err
          assert.equal(versions.length, 1)
          CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 3, done)
        )

      it 'should be able rollback once with many migrations', (done)->
        @tableName = 'many_migrations'
        rollbackScopeDefault(@adapter, migrationsPath, @tableName, (err, versions)=>
          return done(err) if err
          assert.equal(versions.length, 4)
          CustomAssertions.assertTableColumnCount(@AdapterWrapper, @tableName, 2, done)
        )
