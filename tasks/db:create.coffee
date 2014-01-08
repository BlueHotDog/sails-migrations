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
    databaseTasks.create(config.defaultAdapter, (err)->
      console.log("database created", err);
      done()
    )
  )

  grunt.registerTask("db:create", "run database migrations", ['migration:loadConfig', 'db:createInternalTask'])