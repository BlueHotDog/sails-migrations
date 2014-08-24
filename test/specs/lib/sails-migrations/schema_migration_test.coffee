GeneralHelper = require('../../helpers/general')
Promise = require('bluebird')
version = process.env.SAILS_VERSION

describe "SailsIntegration v#{version}", ->
  describe 'SchemaMigration', ->
    before (done)->
      GeneralHelper.getOurAdapter(version).then((schemaMigration)=>
        @SchemaMigration = schemaMigration
        done()
      )

    beforeEach (done)->
      GeneralHelper.recreateSchemaTable(version).done(->done())

    describe 'getAllVersions', ->
      describe 'when no versions', ->
        it 'should return an empty array', (done)->
          @SchemaMigration.getAllVersions(@adapter, (err, versions)=>
            return done(err) if err
            expect(versions).to.be.empty
            done()
          )

      it 'should return only created versions', (done)->
        versionSample = '123'
        @SchemaMigration.create({version: versionSample}, (err)=>
          return done(err) if err
          @SchemaMigration.getAllVersions((err, versions)=>
            return done(err) if err
            expect(versions).to.have.members([versionSample])
            done()
          )
        )

    describe 'deleteAllByVersion', ->
      it 'should only remove given version', (done)->
        #TODO: finish this
        versions = [{version: '123'}, {version: '333'}]
        @SchemaMigration.create(versions, (err)=>
          return done(err) if err
          @SchemaMigration.deleteAllByVersion(versions[0].version, (err)=>
            return done(err) if err
            @SchemaMigration.getAllVersions((err, result)=>
              return done(err) if err
              expect(result).to.not.have.members([versions[0]])
              done()
            )
          )
        )

    describe 'create', ->
      it 'should be able to create a version with attributes', (done)->
        versionSample = '123'
        @SchemaMigration.create({version: versionSample}, (err, model)=>
          return done(err) if err
          expect(model.version).to.equal(versionSample)
          done()
        )
