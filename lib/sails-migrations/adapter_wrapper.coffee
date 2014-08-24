class Adapter
  constructor: (@adapter, @connectionName)->

  define: (tableName, definition, cb)->
    @adapter.define(@connectionName, tableName, definition, cb)

  drop: (tableName, cb)->
    @adapter.drop(tableName, cb)

  addAttribute: (tableName, attrName, attrDef, cb)->
    @adapter.addAttribute(tableName, attrName, attrDef, cb)

  removeAttribute: (tableName, attrName, cb)->
    @adapter.removeAttribute(tableName, attrName, cb)

  query: (query, data, cb)->
    tableName = 'query'
    @adapter.query(tableName, query, data, cb)

  teardown: (cb)->
    debugger
    @adapter.teardown(@connectionName, cb)

  describe: (tableName, cb)->
    @adapter.describe(@connectionName, tableName, cb)

module.exports = Adapter
