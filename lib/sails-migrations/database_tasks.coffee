exec = require('child_process').exec
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

  @migrations_paths: ->
    #TODO: sails should have something similar to rails Rails.application.paths['db/migrate'].to_a
    @migrations_paths ||= 'db/migrate'

  @drop: (adapter, cb)->
    switch adapter.identity
      when 'sails-mysql'
        @executeQuery(adapter, "DROP DATABASE #{adapter.config.database}", (err, stdout, stdin)->
          return cb(err)
        )


module.exports = DatabaseTasks