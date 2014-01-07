###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
dot = require('dot')
_s = require('underscore.string')
fs = require('fs')
path = require('path')
moment = require('moment')

module.exports = (grunt) ->
  migration = require("#{grunt.config.get('basePath')}/lib/sails-migrations/migration")
  grunt.registerTask("migration:generateTask", "generate a migration file", ()->
    @requires("migration:loadConfig")
    @requiresConfig("migration.config")
    templatesPath = grunt.config.get("migration.config.templatesPath")
    migrationFullname = migration.generateMigrationName(grunt.option('name'))
    migrationOutDir = grunt.config.get("migration.config.migrationOutDir")
    migrationPath = path.join(migrationOutDir,"#{migrationFullname}.js")

    templates = dot.process(path: templatesPath)
    migrationContent = templates.migration(username: "moshe", creationDate:  moment().format())

    fs.writeFileSync(migrationPath, migrationContent)
  )

  grunt.registerTask("migration:generate", ['migration:loadConfig', 'migration:generateTask'])
