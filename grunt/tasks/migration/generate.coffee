###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
dot = require('dot')
_s = require('underscore.string')
fs = require('fs')

module.exports = (grunt) ->
  migration = require("#{grunt.config.get('basePath')}/lib/sails-migrations/migration")
  grunt.registerTask("migration:generate", "generate a migration file", ()->
    gakeDir = grunt.config.get('gake').tasksDir
    generateTemplate = "#{grunt.config.get('basePath')}/#{gakeDir}/migration/templates"

    migrationName = _s.underscored(grunt.option('name'))
    migrationNumber = migration.nextMigrationNumber()
    migrationFullname = "#{migrationName}_#{migrationNumber}.js"
    migrationPath = "./migrations/#{migrationFullname}"

    templates = dot.process(path: generateTemplate)
    migrationContent = templates.migration(username: "moshe", creationDate: migrationNumber)
    console.log(migrationContent)

    fs.writeFileSync(migrationPath, migrationContent)
    console.log('hi')
  )
