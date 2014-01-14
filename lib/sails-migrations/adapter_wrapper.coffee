class Adapter
  constructor: (@adapter)->

  registerCollection: (tableName, cb)->
    @adapter.registerCollection({ identity: tableName, config: @adapter.config }, cb)

  define: (tableName, definition, cb)->
    @registerCollection(tableName, (err)=>
      return cb(err) if err
      @adapter.define(tableName, definition, cb)
    )

  drop: (tableName, cb)->
    @registerCollection(tableName, (err)=>
      return cb(err) if err
      @adapter.drop(tableName, cb)
    )

  addAttribute: (tableName, attrName, attrDef, cb)->
    @registerCollection(tableName, (err)=>
      return cb(err) if err
      @adapter.addAttribute(tableName, attrName, attrDef, cb)
    )

  removeAttribute: (tableName, attrName, cb)->
    @registerCollection(tableName, (err)=>
      return cb(err) if err
      @adapter.removeAttribute(tableName, attrName, cb)
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
