GeneralHelper = require('../../helpers/general')
SchemaMigration = rek("lib/sails-migrations/models/schema_migration.coffee")
Promise = require('bluebird')

describe 'SchemaMigration', ->
  before (done)->
    GeneralHelper.getOurAdapter().then((@ourAdapter)=>
      @adapter = @ourAdapter.adapter
      done()
    )

  beforeEach (done)->
    GeneralHelper.recreateSchemaTable().done(->done())

  after (done)->
    SchemaMigration.drop(@adapter, ()->
      done()
    )
  describe "getInstance", ->
    it 'should return a new instance', (done)->
      SchemaMigration.getInstance(@adapter, (err, res) =>
        return done(err) if err
        expect(res).to.be.an.instanceof(SchemaMigration)
        done()
      )

  describe 'define', ->
    it 'should create the table', (done)->
      SchemaMigration.drop(@adapter, (err, res)=>
        return done(err) if err
        SchemaMigration.define(@adapter, (err, schema)=>
          return done(err) if err #not having an error is an assert enough for us
          done()
        )
      )

  describe 'describe', ->
    it 'should return the schema correctly', (done)->
      SchemaMigration.describe(@adapter, (err, schema)=>
        return done(err) if err
        expect(schema).to.have.property('version')
        done()
      )

  describe 'drop', ->
    it 'should drop the table', (done)->
      SchemaMigration.drop(@adapter, (err, res)=>
        return done(err) if err
        SchemaMigration.describe(@adapter, (err, schema)=>
          return done(err) if err
          expect(schema).to.be.undefined
          done()
        )
      )

  describe 'getAllVersions', ->
    describe 'when no versions', ->
      it 'should return an empty array', (done)->
        SchemaMigration.getAllVersions(@adapter, (err, versions)=>
          return done(err) if err
          expect(versions).to.be.empty
          done()
        )

    it 'should return only created versions', (done)->
      versionSample = '123'
      SchemaMigration.create(@adapter, {version: versionSample}, (err)=>
        return done(err) if err
        SchemaMigration.getAllVersions(@adapter, (err, versions)=>
          return done(err) if err
          expect(versions).to.have.members([versionSample])
          done()
        )
      )

  describe 'deleteAllByVersion', ->
    it 'should only remove given version', (done)->
      #TODO: finish this
      versions = [{version: '123'}, {version: '333'}]
      SchemaMigration.create(@adapter, versions, (err)=>
        return done(err) if err
        SchemaMigration.deleteAllByVersion(@adapter, versions[0].version, (err)=>
          return done(err) if err
          SchemaMigration.getAllVersions(@adapter, (err, result)=>
            return done(err) if err
            expect(result).to.not.have.members([versions[0]])
            done()
          )
        )
      )

  describe 'create', ->
    it 'should be able to create a version with attributes', (done)->
      versionSample = '123'
      SchemaMigration.create(@adapter, {version: versionSample}, (err, model)=>
        return done(err) if err
        expect(model.version).to.equal(versionSample)
        done()
      )
