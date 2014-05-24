path = require('path')
Waterline = require(path.join(process.cwd(), 'node_modules', 'sails', 'node_modules', 'waterline'))
SailsIntegration = require('./sails_integration')
_ = require('lodash')

TABLE_NAME = "sails_schema_migrations"
INDEX_NAME = "unique_schema_migrations"
attributes =
  version:
    type: 'STRING'
    primaryKey: true
    required: true
    index: true
    #null: true TODO: how do we validate this?

SchemaMigration = Waterline.Collection.extend({
#  tableName: TABLE_NAME
  migrate: 'safe'
  autoCreatedAt: false
  autoUpdatedAt: false
  connection: "sailsMigrationsAdapter"
  identity: TABLE_NAME
  schema: false
  attributes: attributes
})

SchemaMigration.getInstance = (adapter, cb)->
  options = {
    connections: {
      sailsMigrationsAdapter: adapter
    }
  }
  baseAppPath = process.cwd()
  modulesPath = path.join(baseAppPath, 'node_modules')
  SailsIntegration.loadSailsConfig(modulesPath, (err, conf)->
    sails = require(conf.sailsPath)
    debugger
    for k,v of sails
      console.log(k)
#    new SchemaMigration(sails, options, cb)
  )

SchemaMigration.create = (adapter, attributes, cb)->
  @getInstance(adapter, (err, Model)->
    return cb(err) if err
    Model.create(attributes).exec(cb)
  )

SchemaMigration.define = (adapter, cb)->
  orm = new Waterline()

  baseAppPath = process.cwd()
  modulesPath = path.join(baseAppPath, 'node_modules')
  SailsIntegration.loadSailsConfig(modulesPath, (err, conf)->
    sails = require(conf.sailsPath)
    defConnection = sails.config.models.connection
    defAdapter = sails.config.connections[defConnection]
    newConf = {
      connections: {},
      adapters: {
        default: conf.defaultAdapter
      },
      defaults: {
        migrate: 'safe'
      }
    }
    newConf.connections[defConnection] = defAdapter
    newConf.adapters[defAdapter.adapter] = conf.defaultAdapter
    SchemaMigration::connection = defConnection

    orm.loadCollection(SchemaMigration)

    orm.initialize(newConf, (err, models)->

      models.collections[TABLE_NAME].define(models.collections[TABLE_NAME].attributes, (err,models)->
        console.log(arguments)
        cb()
      )
    )
  #    new SchemaMigration(sails, options, cb)
  )
#  console.dir(orm.collections.sailsMigration.define)

#  orm.collections.sailsMigration.define(Model.attributes, cb)
#  @getInstance(adapter, (err, Model)->
#    return cb(err) if err
#    Model.define(Model.attributes, cb)
#  )

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
