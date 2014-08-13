TABLE_NAME = "sails_schema_migrations"

Waterline = require('waterline')
_ = require('lodash')

SchemaMigration = Waterline.Collection.extend({
  tableName: TABLE_NAME
  migrate: 'safe'
  autoCreatedAt: false
  autoUpdatedAt: false
  autoPK: false
  attributes:
    version:
      type: 'STRING'
      primaryKey: true
      required: true
      index: true
      #null: true TODO: how do we validate this?

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

  define: (cb)->
    console.log 'define'
    @define(@attributes, cb)
})

module.exports = SchemaMigration
