###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
S = require('string')
dot = require('dot')

module.exports = (grunt) ->
  migration = require("#{grunt.config.get('basePath')}/lib/sails-migrations/migration")
  grunt.registerTask("migration:generate", "generate a migration file", ()->
    migrationNumber = migration.nextMigrationNumber()
    console.log(grunt.config.get(""))
  )