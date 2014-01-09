exec = require('child_process').exec
LOCAL_HOSTS = ['127.0.0.1', 'localhost']
class DatabaseTasks
  @create: (adapter, cb)->
    console.log(adapter.config)
    switch adapter.identity
      when 'sails-mysql'
        exec("mysql -h #{adapter.config.host} -u #{adapter.config.user} -p#{adapter.config.password} -e 'CREATE DATABASE IF NOT EXISTS #{adapter.config.database}'", (err, stdout, stdin)->
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