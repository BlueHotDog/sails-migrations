###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
path = require('path')

module.exports = (grunt, done) ->
  grunt.registerTask('migration:statusTask', 'checks the status of the migrations', ()->
    done = @async()
    @requires('migration:loadConfig')
    #@requiresConfig('migration.config')

    adapter = grunt.config.get('migration.config.adapter')
    console.log adapter
    SchemaMigration = require("#{grunt.config.get('migration.config.migrationLibPath')}/schema_migration")(adapter)
    s = new SchemaMigration({}, (err, Model)->
      debugger
      Model._adapter = adapter
      result = Model.create(version: 1).done( (err, result)->
        console.log err, result
        done()
      )
    )
  )

  grunt.registerTask('migration:status', ['migration:loadConfig', 'migration:statusTask'])

