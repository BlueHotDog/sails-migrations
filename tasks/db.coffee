###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
dot = require('dot')
fs = require('fs')
path = require('path')
moment = require('moment')

module.exports = (grunt) ->
  grunt.registerTask("db:createInternalTask", ->
    @requires("migration:loadConfig")
    @requiresConfig("migration.config")

    config = grunt.config.get('migration.config')
    done = @async()

    databaseTasks = require(path.join(config.migrationLibPath, "database_tasks"))
    grunt.log.writeln("Trying to create a new database")
    databaseTasks.create(config.defaultAdapter, (err)->
      return grunt.fail.fatal(err) if err
      grunt.log.oklns("Database created successfully")
      done()
    )
  )

  grunt.registerTask("db:create", "run database migrations", ['migration:loadConfig', 'db:createInternalTask'])



  grunt.registerTask("db:dropInternalTask", ->
    @requires("migration:loadConfig")
    @requiresConfig("migration.config")

    config = grunt.config.get('migration.config')
    done = @async()

    databaseTasks = require(path.join(config.migrationLibPath, "database_tasks"))
    grunt.log.writeln("Trying to drop the database")
    databaseTasks.drop(config.defaultAdapter, (err)->
      return grunt.fail.fatal(err) if err
      grunt.log.oklns("Database dropped sucessfully")
      done()
    )
  )

  grunt.registerTask("db:drop", "drops the database", ['migration:loadConfig', 'db:dropInternalTask'])


  grunt.registerTask("db:reset", "recreates the database", ['migration:loadConfig', 'db:dropInternalTask', 'db:createInternalTask'])
