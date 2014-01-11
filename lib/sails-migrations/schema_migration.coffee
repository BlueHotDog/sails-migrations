TABLE_NAME = "sails_schema_migrations"
INDEX_NAME = "unique_schema_migrations"

Waterline = require('waterline')
SailsIntegration = require('./sails_integration')

class SchemaMigration extends Waterline.Collection
  tableName: TABLE_NAME
  migrate: 'safe'
  autoCreatedAt: false
  autoUpdatedAt: false
  attributes:
    version:
      type: 'STRING'
      primaryKey: true
      required: true
      index: true
      #null: true TODO: how do we validate this?

  @getInstance: (adapter, cb)->
    options = {adapters:{}}
    options.adapters["adapter"] = adapter
    SchemaMigration::adapter = "adapter"
    new @(options, cb)


  @define: (adapter, cb)->
    @getInstance(adapter, (err, Model)->
      return cb(err) if err
      Model.define(Model.attributes, cb)
    )

module.exports = SchemaMigration