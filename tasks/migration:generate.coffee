###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
dot = require('dot')
fs = require('fs')
path = require('path')
moment = require('moment')

module.exports = (grunt) ->
  grunt.registerTask("migration:generateInternalTask", ->
    @requires("migration:loadConfig")
    @requiresConfig("migration.config")
    grunt.fail.fatal("The --name parameter is required") unless grunt.option('name')

    config = grunt.config.get('migration.config')

    migration = require(path.join(config.migrationLibPath, "migration"))
    migrationFullname = migration.generateMigrationName(grunt.option('name'))
    migrationPath = path.join(config.migrationOutDir,"#{migrationFullname}.js")

    templates = dot.process(path: config.templatesPath)
    migrationContent = templates.migration(username: "moshe", creationDate:  moment().format())

    fs.writeFileSync(migrationPath, migrationContent)
  )

  grunt.registerTask("migration:generate", "run database migrations", ['migration:loadConfig', 'migration:generateInternalTask'])