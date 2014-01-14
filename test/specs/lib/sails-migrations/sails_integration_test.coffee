SailsIntegration = rek('lib/sails-migrations/sails_integration')
path = require('path')

describe 'SailsIntegration', ->
  sandbox = sinon.sandbox.create()

  before ->
    @modulesPath = path.resolve("test/example_app/node_modules")
    @Sails = require(path.join(@modulesPath, 'sails'))

  afterEach ->
    sandbox.restore()

  describe 'loadSailsConfig', ->
    describe 'first call', ->
      context 'when there is an error', ->
        beforeEach ->
          sandbox.stub(@Sails, 'load').yields('some err')

        it 'should return the error', (done)->
          SailsIntegration.loadSailsConfig(@modulesPath, (err, config)->
            expect(err).to.equal('some err')
            expect(config).to.be.empty
            done()
          )

      context 'when there is no error', ->
        beforeEach ->
          sandbox.stub(@Sails, 'load').yields()

        it 'should get config', (done)->
          sandbox.mock(SailsIntegration).expects('getSailsConfig').once()
          SailsIntegration.loadSailsConfig(@modulesPath, done)

    describe 'second call', ->
      beforeEach ->
        sandbox.stub(@Sails, 'load').yields()

      it 'should return cache', (done)->
        mock = sandbox.mock(SailsIntegration).expects('getSailsConfig').once().returns(a: 3)
        SailsIntegration.loadSailsConfig(@modulesPath, (err, config)=>
          SailsIntegration.loadSailsConfig(@modulesPath, (err, config)=>
            expect(config).to.deep.equal(a: 3)
            mock.verify()
            done()
          )
        )
  describe 'getSailsConfig', ->
    before ->
      @sailsWithConfig =
        config:
          adapters:
            default: 'defaultAdapter'
            defaultAdapter:
              module: 'sails-mysql' #well, we need to load some module we KNOW is there, this should do

    it 'should return the correct config', ->
      config = SailsIntegration.getSailsConfig(@modulesPath, @sailsWithConfig)
      expect(config).to.have.keys(['migrationLibPath','defaultAdapterName','defaultAdapter', 'sailsPath'])