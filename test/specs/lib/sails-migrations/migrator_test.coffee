Migrator = rek('lib/sails-migrations/migrator.coffee')

describe 'Migrator', ->
  sandbox = sinon.sandbox.create()

  describe 'Static methods', ->
    describe 'migrate', ->
      context 'when no targetVersion is given', ->
        beforeEach ->
          @adapter = sandbox.stub()
          @migrationsPaths = sandbox.stub()

        it 'should call move in the up direction', ->
          expect(Migrator)
  afterEach ->
    sandbox.restore()
