TABLE_NAME = "sails_schema_migrations"
INDEX_NAME = "unique_schema_migrations"

Waterline = require('waterline')
SailsIntegration = require('./sails_integration')
_ = require('lodash')

SchemaMigration = Waterline.Collection.extend({
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
})

SchemaMigration.getInstance = (adapter, cb)->
  options = {adapters: {}}
  options.adapters["adapter"] = adapter
  SchemaMigration::adapter = "adapter"
  new SchemaMigration(options, cb)

SchemaMigration.create = (adapter, attributes, cb)->
  @getInstance(adapter, (err, Model)->
    return cb(err) if err
    Model.create(attributes).exec(cb)
  )

SchemaMigration.define = (adapter, cb)->
  @getInstance(adapter, (err, Model)->
    return cb(err) if err
    Model.define(Model.attributes, cb)
  )

SchemaMigration.describe = (adapter, cb)->
  @getInstance(adapter, (err, Model)->
    return cb(err) if err
    Model.describe(cb)
  )

SchemaMigration.drop = (adapter, cb)->
  @getInstance(adapter, (err, Model)->
    return cb(err) if err
    Model.drop(cb)
  )

SchemaMigration.getAllVersions = (adapter, cb)->
  @getInstance(adapter, (err, Model)=>
    Model.find().exec((err, models)=>
      return cb(err) if err
      cb(null, _.pluck(models, 'version'))
    )
  )

SchemaMigration.deleteAllByVersion = (adapter, version, cb)->
  @getInstance(adapter, (err, Model)=>
    return cb(err) if err
    Model.find().where({version: version}).exec((err, models)=>
      return cb(err) if err
      models[0].destroy(cb)
    )
  )

module.exports = SchemaMigration
