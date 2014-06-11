_ = require('lodash')
Sequelize = require('sequelize')

getDatabaseName = (adapter)->
  switch adapter.identity
    when 'sails-mysql'
      'mysql'
    when 'sails-postgresql'
      'postgres'
    else
      throw "unsupported database #{adapter.identity}"

class Migrator
  @getSequelizeInstance: (adapter)->
    options = {
      host: adapter.config.host
      port: adapter.config.port
      dialect: getDatabaseName(adapter)
    }
    new Sequelize(adapter.config.database, adapter.config.user, adapter.config.password, options)

  @getMigrator: (adapter, options)->
    @getSequelizeInstance(adapter).getMigrator(options)


module.exports = Migrator
