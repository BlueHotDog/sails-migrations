MigrationRunner = rek('lib/sails-migrations/migration_runner')
Promise = require('bluebird')

class MigrationThatThrowsAnErrorOnUp
  @up: (adapter, cb)->
    throw new Error("ERR")

class MigrationWithPromise
  @up: (adapter)->
    resolver = Promise.defer()
    setTimeout((->resolver.resolve("resolve value")),2)
    resolver.promise

  @down: (adapter)->
    resolver = Promise.defer()
    setTimeout((->resolver.reject("some err")),2)
    resolver.promise

class MigrationWithCallback
  @up: (adapter, cb)->
    setTimeout(cb,2)
  @down: (adapter, cb)->
    return cb()

describe 'MigrationRunner', ->
  sandbox = sinon.sandbox.create()

  afterEach ->
    sandbox.restore()

  before ->
    @adapter = new Object();
    @invalidMigrationData = {some:'object'}
    @validMigrationData = {
      version: '1',
      name: 'my_migration',
      path: 'some/path'
    }

  context 'when giving invalid migration data', ->
    describe 'constructor', ->
      it 'should throw an exception', ->
        expect(->new MigrationRunner()).to.throw(Error)
        expect(->new MigrationRunner(@invalidMigrationData)).to.throw(Error)


  context 'when giving a valid migration data', ->
    beforeEach ->
      @migrationRunner = new MigrationRunner(@validMigrationData)

    describe 'constructor', ->
      it 'should set the migrationData object', ->
        runner = new MigrationRunner(@validMigrationData)
        expect(runner.migrationData).to.deep.equal(@validMigrationData)

    describe 'up', ->
      context 'when given a migration with a callback', ->
        beforeEach ->
          sandbox.stub(@migrationRunner, "requireMigration").returns(MigrationWithCallback)

        it 'should call the up method with a callback', (done)->
          spy = sandbox.spy(MigrationWithCallback, "up")
          @migrationRunner.up(@adapter, (err)->
            return done(err) if err
            expect(spy.calledOnce).to.be.true
            done()
          )

      # testing promises
      context 'when given a migration without a callback', ->
        beforeEach ->
          sandbox.stub(@migrationRunner, "requireMigration").returns(MigrationWithPromise)

        context 'when the up function returns a promise', ->
          context 'when the promise is resolved', ->
            it 'should call the callback once the promise resolved', (done)->
              @migrationRunner.up(@adapter, (err, resolveValue) ->
                return done(err) if err
                expect(resolveValue).to.equal("resolve value")
                done()
              )

          context 'when the promise is rejected', ->
            it 'should call the callback with an error', (done)->
              @migrationRunner.down(@adapter, (err) ->
                expect(err).to.not.be.empty
                done()
              )
          context 'when the migration throws', ->
            beforeEach ->
              sandbox.restore()
              sandbox.stub(@migrationRunner, "requireMigration").returns(MigrationThatThrowsAnErrorOnUp)

            it 'should pass the error to the err param', (done)->
              @migrationRunner.up(@adapter, (err) ->
                expect(err.message).to.equal('ERR')
                done()
              )
