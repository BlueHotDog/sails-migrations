###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
dot = require('dot')
_s = require('underscore.string')
fs = require('fs')
moment = require('moment')

module.exports = (grunt) ->
  migration = require("#{grunt.config.get('basePath')}/lib/sails-migrations/migration")
  grunt.registerTask("migration:generate", "generate a migration file", ()->
    grunt.task.run(['migration:loadConfig'])
    @requires("migration:loadConfig")
    @requiresConfig("migration.config")
    templatesPath = grunt.config.get("migration.config.templatesPath")
    migrationFullname = migration.generateMigrationName(grunt.option('name'))
    migrationPath = "./migrations/#{migrationFullname}.js"

    templates = dot.process(path: templatesPath)
    migrationContent = templates.migration(username: "moshe", creationDate:  moment().format())

    fs.writeFileSync(migrationPath, migrationContent)
  )
