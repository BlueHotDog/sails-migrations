class Adapter
  constructor: (@adapter, @connectionName)->
    @collections = {}

  define: (tableName, definition, cb)->
    @_setup(tableName, (err)=>
      return cb(err) if err

      @adapter.define(@connectionName, tableName, definition, cb)
    )

  drop: (tableName, cb)->
    @_setup(tableName, (err)=>
      return cb(err) if err

      @adapter.drop(@connectionName, tableName, cb)
    )

  addAttribute: (tableName, attrName, attrDef, cb)->
    @_setup(tableName, (err)=>
      return cb(err) if err

      @adapter.addAttribute(@connectionName, tableName, attrName, attrDef, cb)
    )

  removeAttribute: (tableName, attrName, cb)->
    @_setup(tableName, (err)=>
      return cb(err) if err

      @adapter.removeAttribute(@connectionName, tableName, attrName, cb)
    )

  query: (query, data, cb)->
    tableName = 'query'
    @_setup(tableName, (err)=>
      return cb(err) if err

      @adapter.query(@connectionName, tableName, query, data, cb)
    )

  teardown: (cb)->
    @adapter.teardown(@connectionName, cb)

  describe: (tableName, cb)->
    @_setup(tableName, (err)=>
      return cb(err) if err

      @adapter.describe(@connectionName, tableName, cb)
    )

  _setup: (tableName, cb)->
    connection = 
      identity: @connectionName
    collections = {}
    collections[tableName] = {}
    collections['schema_migration'] = {}
    @teardown((err)=>
      return cb(err) if err

      @adapter.registerConnection(connection, collections, cb)
    )

module.exports = Adapter
