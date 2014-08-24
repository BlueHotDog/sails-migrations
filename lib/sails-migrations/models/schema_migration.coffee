TABLE_NAME = "sails_schema_migrations"

Waterline = require('waterline')
_ = require('lodash')
attributes = 
  version:
    type: 'string'
    primaryKey: true
    required: true
    index: true

SchemaMigration = Waterline.Collection.extend({
  tableName: TABLE_NAME
  migrate: 'safe'
  autoCreatedAt: false
  autoUpdatedAt: false
  autoPK: false
  definition: attributes
  schema: attributes
  _schema: attributes
}, {
  attributes: attributes

  getAllVersions: (cb)->
    @find().exec((err, models)=>
      return cb(err) if err
      cb(null, _.pluck(models, 'version'))
    )

  deleteAllByVersion: (version, cb)->
    @find().where({version: version}).exec((err, models)=>
      return cb(err) if err
      models[0].destroy(cb)
    )
})

module.exports = SchemaMigration
