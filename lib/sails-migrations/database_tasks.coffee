exec = require('child_process').exec
LOCAL_HOSTS = ['127.0.0.1', 'localhost']
class DatabaseTasks
  @create: (adapter, cb)->
    switch adapter.identity
      when 'sails-mysql'
        exec("mysql -u #{adapter.config.username} -p#{adapter.config.password} -e 'CREATE DATABASE IF NOT EXISTS #{adapter.config.database}'", (err, stdout, stdin)->
          console.log(arguments)
          return cb(err)
        )
    # impossible currently since the following code crashes

  @migrations_paths: ->
    #TODO: sails should have something similar to rails Rails.application.paths['db/migrate'].to_a
    @migrations_paths ||= 'db/migrate'

  @drop: ->
    #TODO: waterline needs to add support for dropping a database



module.exports = DatabaseTasks