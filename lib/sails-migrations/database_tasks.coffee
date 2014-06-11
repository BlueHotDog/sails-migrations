exec = require('child_process').exec
_ = require('lodash')



class DatabaseTasks

  @executeQuery = (adapter, query, cb) ->
    switch adapter.identity
      when 'sails-mysql'
        passwordField = ''
        passwordField = "-p#{adapter.config.password}" unless _.isEmpty(adapter.config.password)
        exec("mysql -h #{adapter.config.host} -u #{adapter.config.user} #{passwordField} -e '#{query}'", cb)
      when 'sails-postgresql'
        command = "psql -U #{adapter.config.user} -h #{adapter.config.host} postgres -c '#{query}'"
        console.log(command)
        exec(command, cb)

  @create: (adapter, cb)->
      @executeQuery(adapter, "CREATE DATABASE #{adapter.config.database}", (err, stdout, stdin)=>
        cb(err, adapter)
      )

  @migrationsPath: ->
    #TODO: sails should have something similar to rails Rails.application.paths['db/migrate'].to_a
    @migrationsPath ||= 'db/migrate'

  @drop: (adapter, cb)->
    @executeQuery(adapter, "DROP DATABASE '#{adapter.config.database}'", (err, stdout, stdin)->
      return cb(err, adapter)
    )


module.exports = DatabaseTasks
