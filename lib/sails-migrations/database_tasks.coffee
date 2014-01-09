exec = require('child_process').exec
LOCAL_HOSTS = ['127.0.0.1', 'localhost']
class DatabaseTasks
  executeSql = (adapter, cb) ->

  @create: (adapter, cb)->
    switch adapter.identity
      when 'sails-mysql'
        exec("mysql -h #{adapter.config.host} -u #{adapter.config.user} -p#{adapter.config.password} -e 'CREATE DATABASE #{adapter.config.database}'", (err, stdout, stdin)->
          return cb(err)
        )
    # impossible currently since the following code crashes

  @migrations_paths: ->
    #TODO: sails should have something similar to rails Rails.application.paths['db/migrate'].to_a
    @migrations_paths ||= 'db/migrate'

  @drop: (adapter, cb)->
    switch adapter.identity
      when 'sails-mysql'
        exec("mysql -h #{adapter.config.host} -u #{adapter.config.user} -p#{adapter.config.password} -e 'DROP DATABASE #{adapter.config.database}'", (err, stdout, stdin)->
          return cb(err)
        )
    #TODO: waterline needs to add support for dropping a database



module.exports = DatabaseTasks