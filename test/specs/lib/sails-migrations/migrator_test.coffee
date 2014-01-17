Migrator = rek('lib/sails-migrations/migrator.coffee')

describe 'Migrator', ->
  sandbox = sinon.sandbox.create()

  afterEach ->
    sandbox.restore()

  #TODO: do it.

