###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
path = require('path')

module.exports = (grunt) ->
  grunt.registerTask('migration:statusTask', 'checks the status of the migrations', ()->
    done = @async()
    @requires('migration:loadConfig')
    @requiresConfig('migration.config')

    config = grunt.config.get('migration.config')
    SchemaMigration = require("#{grunt.config.get('migration.config.migrationLibPath')}/schema_migration")(config.defaultAdapterName)

    SchemaMigration.create(options, (err, Model)->
      console.log(err,Model)
      done()
    )
    new SchemaMigration(options, (err, Model)->
#      grunt.log.writeln("Checking if #{SchemaMigration::tableName} exists")
      Model.describe((err, attributes)->
#        return grunt.fail.fatal(err) if err
#        return grunt.fail.fatal("#{SchemaMigration::tableName} does not exists") unless attributes
#
#        done()
      )
    )
  )

  grunt.registerTask('migration:status', 'Display status of migrations', ['migration:loadConfig', 'migration:statusTask'])

