dot = require('dot')
fs = require('fs')
path = require('path')
moment = require('moment')
Sequelize = require('sequelize')


module.exports = (grunt) ->
  grunt.registerTask("db:createInternalTask", ->
    @requires("db:loadConfig")
    @requiresConfig("migration.config")

    config = grunt.config.get('migration.config')
    done = @async()

    databaseTasks = grunt.helpers.loadLibModule("database_tasks")
    MigratorHelper = grunt.helpers.loadLibModule('migrator_helper')

    grunt.log.writeln("Trying to create a new database")

    adapter = config.defaultAdapter

    databaseTasks.create(adapter, (err)->
      return grunt.fail.fatal(err) if err
      grunt.log.oklns("Database created successfully")

      grunt.log.writeln("Creating version table")

      migrator = MigratorHelper.getMigrator(adapter, {
        path: config.migrationOutDir
      })

      migrator.findOrCreateSequelizeMetaDAO().success(->
        grunt.log.oklns("table created successfully")
        done()
      ).error(grunt.fail.fatal)
    )
  )

  grunt.registerTask("db:create", "run database migrations", ['db:loadConfig', 'db:createInternalTask'])

  grunt.registerTask("db:dropInternalTask", ->
    @requires("db:loadConfig")
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

  grunt.registerTask("db:drop", "drops the database", ['db:loadConfig', 'db:dropInternalTask'])



  grunt.registerTask("db:reset", "recreates the database", ['db:loadConfig', 'db:dropInternalTask', 'db:createInternalTask'])
