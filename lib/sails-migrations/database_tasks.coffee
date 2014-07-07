exec = require('child_process').exec
_ = require('lodash')
errors = require('./errors')

LOCAL_HOSTS = ['127.0.0.1', 'localhost']
class DatabaseTasks
  @executeQuery = (adapter, query, cb) ->
    switch adapter.identity
      when 'sails-mysql'
        passwordField = ''
        passwordField = "-p#{adapter.config.password}" unless _.isEmpty(adapter.config.password)
        exec("mysql -h #{adapter.config.host} -u #{adapter.config.user} #{passwordField} -e '#{query}'", cb)
      when 'sails-postgresql'
        # use .pgpass or no password
        exec("psql -h #{adapter.config.host} -U #{adapter.config.user} -d #{adapter.config.database} -c '#{query}'", cb)

  @create: (adapter, cb)->
    switch adapter.identity
      when 'sails-mysql'
        @executeQuery(adapter, "CREATE DATABASE #{adapter.config.database}", (err, stdout, stdin)=>
          cb(err, adapter)
        )
      when 'sails-postgresql'
        exec("createdb #{adapter.config.database}", (err)=>
          if err?.toString().match(/already exists/)
            cb(new errors.DatabaseAlreadyExists(err, adapter), adapter)
          else
            cb(err, adapter)
        )

  @migrationsPath: ->
    #TODO: sails should have something similar to rails Rails.application.paths['db/migrate'].to_a
    @migrationsPath ||= 'db/migrate'

  @drop: (adapter, cb)->
    switch adapter.identity
      when 'sails-mysql'
        @executeQuery(adapter, "DROP DATABASE IF EXISTS #{adapter.config.database}", (err, stdout, stdin)->
          cb(err, adapter)
        )
      when 'sails-postgresql'
        exec("dropdb #{adapter.config.database}", (err)=>
          cb(err, adapter)
        )

  @dropSchema: (adapter, cb)->
    switch adapter.identity
      when 'sails-mysql'
        @drop(adapter, cb)
      when 'sails-postgresql'
        exec("psql -l | grep #{adapter.config.database} | wc -l", (err, stdout, stdin)=>
          if stdout.match("1")
            @executeQuery(adapter, "DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;", (err, stdout, stdin)->
              cb(err, adapter)
            )
          else
            cb(err, adapter)
        )

module.exports = DatabaseTasks
