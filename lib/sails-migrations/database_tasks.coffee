exec = require('child_process').exec
_ = require('lodash')
Migration = require('./migration')
MigrationRunner = require('./migration_runner')
LOCAL_HOSTS = ['127.0.0.1', 'localhost']
class DatabaseTasks
  @executeQuery = (adapter, query, cb) ->
    switch adapter.identity
      when 'sails-mysql'
        exec("mysql -h #{adapter.config.host} -u #{adapter.config.user} -p#{adapter.config.password} -e '#{query}'", cb)

  @create: (adapter, cb)->
    switch adapter.identity
      when 'sails-mysql'
        @executeQuery(adapter, "CREATE DATABASE #{adapter.config.database}", (err, stdout, stdin)->
          return cb(err)
        )

  @migrationsPath: ->
    #TODO: sails should have something similar to rails Rails.application.paths['db/migrate'].to_a
    @migrationsPath ||= 'db/migrate'

  @migrate: (adapter, cb)->
    Migration.allMigrationFilesParsed(@migrationsPath(), (err, migrations)->
      if _.isEmpty(migrations)
        cb(null, [])
      else
        _.each(migrations, (migration)->
          console.log "running migration #{migration}"
          runner = new MigrationRunner(migration)
          runner.up(adapter, cb)
        )
    )

  @drop: (adapter, cb)->
    switch adapter.identity
      when 'sails-mysql'
        @executeQuery(adapter, "DROP DATABASE #{adapter.config.database}", (err, stdout, stdin)->
          return cb(err)
        )


module.exports = DatabaseTasks
