###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
path = require('path')
_ = require('lodash')
SailsIntegration = require('../lib/sails-migrations/sails_integration')

module.exports = (grunt) ->
  grunt.registerTask("db:loadConfig", "internal task to load all needed configuration", ()->
    done = @async()
    #We're doing this only under test because the example_app configures the sails-migration package to be linked to the local
    #version of sails-migration, and since it will run under the real path of sails-migrations when trying to require 'sails',
    #we have to manually give the path for the example_app sails module
    if process.env.NODE_ENV == 'test'
      baseAppPath = grunt.config.get('basePath')
    else
      baseAppPath = process.cwd()

    modulesPath = path.join(baseAppPath, 'node_modules')
    SailsIntegration.loadSailsConfig(modulesPath, (err, config)->
      return done(err) if err

      config = _.extend(config, {
        migrationOutDir: path.join(baseAppPath, 'db', 'migrations')
        templatesPath: path.join(__dirname, 'templates')
      })

      grunt.config.set('migration.config', config)

      done()
    )
  )
