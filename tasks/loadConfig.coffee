###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
path = require('path')
_ = require('lodash')
SailsIntegration = require('../lib/sails-migrations/sails_integration')

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
    config = SailsIntegration.loadSailsConfig(sails, (err)->
      return done(err) if err

      config = _.extend(config, {
        migrationOutDir: path.join(basePath,"db","migrations")
        templatesPath: path.join(basePath,"#{gakeDir}/migration/templates")
      })

      grunt.config.set('migration.config', config)

      done()
    )
  )
