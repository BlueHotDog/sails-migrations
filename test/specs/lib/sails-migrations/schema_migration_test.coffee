SchemaMigration = rek("lib/sails-migrations/schema_migration.coffee")
ourAdapter = rek("lib/sails-migrations/adapter.coffee")
assert = require('assert')
path = require('path')
SailsIntegration = rek("lib/sails-migrations/sails_integration.coffee")

describe 'SchemaMigration', ->

  beforeEach (done)->
    modulesPath = path.resolve("test/example_app/node_modules")
    SailsIntegration.loadSailsConfig(modulesPath, (err, config)=>
      @config = config
      @adapter = @config.defaultAdapter
      SchemaMigration.define(@adapter, done)
    )

  beforeEach (done)->
    @version = 1
    SchemaMigration.getInstance(@adapter, (err, Model)=>
      return done(err) if err
      @SchemaMigration = Model
      Model.create({version: @version}).exec( (err)=>
        console.log(err) if err
        done()
      )
    )

  describe 'deleteAllByVersion', ->

    it 'should be able to delete by version', (done)->
      SchemaMigration.deleteAllByVersion(@adapter, @version, (err)=>
        return done(err) if err
        @SchemaMigration.find().where({version: @version}).exec( (err, models)->
          return done(err) if err
          assert.equal(models.length, 0)
          done()
        )
      )

  describe 'getAllVersions', ->

    it 'should be able to get all versions', (done)->
      SchemaMigration.getAllVersions(@adapter, (err, versions)=>
        return done(err) if err
        assert.equal(versions.length, 1)
        done()
      )

  describe 'create', ->

    it 'should be able to create a version with attributes', (done)->
      versionSample = '123'
      SchemaMigration.create(@adapter, {version: versionSample}, (err, model)=>
        return done(err) if err
        assert.equal(model.version, versionSample)
        done()
      )

  afterEach (done)->
    new ourAdapter(@adapter).drop(SchemaMigration::tableName, done)
