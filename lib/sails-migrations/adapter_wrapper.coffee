class Adapter
  constructor: (@adapter, @connectionName)->

  define: (tableName, definition, cb)->
    @adapter.define(@connectionName, tableName, definition, cb)

  drop: (tableName, cb)->
    @adapter.drop(@connectionName, tableName, cb)

  addAttribute: (tableName, attrName, attrDef, cb)->
    @adapter.addAttribute(@connectionName, tableName, attrName, attrDef, cb)

  removeAttribute: (tableName, attrName, cb)->
    @adapter.removeAttribute(@connectionName, tableName, attrName, cb)

  query: (query, data, cb)->
    tableName = 'query'
    @adapter.query(@connectionName, tableName, query, data, cb)

  teardown: (cb)->
    @adapter.teardown(@connectionName, cb)

  describe: (tableName, cb)->
    @adapter.describe(@connectionName, tableName, cb)

module.exports = Adapter
