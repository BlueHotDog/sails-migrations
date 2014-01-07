###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
path = require('path')

module.exports = (grunt) ->
  grunt.registerTask("migration:loadConfig", "internal task to load all needed configuration", ()->
    #We're doing this only under test because the test_app configures the sails-migration package to be linked to the local
    #version of sails-migration, and since it will run under the real path of sails-migrations when trying to require 'sails',
    #we have to manually give the path for the test_app sails module
    if process.env.NODE_ENV == 'test'
      sails = require('../test/test_app/node_modules/sails')
      basePath = path.join(grunt.config.get('basePath'), "../../")
    else
      sails = require('sails')
      basePath = grunt.config.get('basePath')

    done = @async()

    options =
      globals: false
      loadHooks: ['moduleloader', 'userconfig', 'orm']

    sails.load(options, (err)->
      console.log('error when loading sails') if err
      gakeDir = grunt.config.get('gake').tasksDir
      defaultAdapterName =  sails.config.adapters.default
      dbConfig = sails.config.adapters[defaultAdapterName]
      adapter = require(path.join(basePath, "test/test_app/node_modules", dbConfig.module))
      adapter.config = dbConfig

      grunt.config.set('migration.config', {
        migrationOutDir: path.join(basePath,"db","migrations")
        templatesPath: path.join(basePath,"#{gakeDir}/migration/templates")
        migrationLibPath: path.join(basePath,"lib/sails-migrations")
        defaultAdapterName: defaultAdapterName
        defaultAdapter: adapter
      })
      done()
    )
  )
