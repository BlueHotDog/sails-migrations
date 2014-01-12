class Adapter
  constructor: (@adapter)->

  define: (tableName, definition, cb)->
    @adapter.registerCollection({ identity: tableName, config: @adapter.config }, (err)=>
      return cb(err) if err
      @adapter.define(tableName, definition, cb)
    )
module.exports = Adapter
