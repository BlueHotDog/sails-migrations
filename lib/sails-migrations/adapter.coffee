class Adapter
  constructor: (@adapter)->

  registerCollection: (tableName, cb)->
    @adapter.registerCollection({ identity: tableName, config: @adapter.config }, cb)

  define: (tableName, definition, cb)->
    @registerCollection(tableName, (err)=>
      return cb(err) if err
      @adapter.define(tableName, definition, cb)
    )

  query: (query, data, cb)->
    tableName = 'query'
    @registerCollection(tableName, (err)=>
      return cb(err) if err
      @adapter.query(tableName, query, data, cb)
    )

  describe: (tableName, cb)->
    @registerCollection(tableName, (err)=>
      return cb(err) if err
      @adapter.describe(tableName, cb)
    )
module.exports = Adapter
