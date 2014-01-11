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
      type: 'INTEGER'
      primaryKey: true
      required: true
      index: true
      #null: true TODO: how do we validate this?

  @getInstance: (sailsConfig, cb)->
    options = {adapters:{}}
    options.adapters[sailsConfig.defaultAdapterName] = sailsConfig.defaultAdapter
    options.adapter = sailsConfig.defaultAdapterName
    new SchemaMigration(options, cb)


  @create: (sailsConfig, cb)->
    @getInstance(sailsConfig, (err, Model)->
      return cb(err) if err
      Model.define(Model.attributes, cb)
    )

module.exports = SchemaMigration