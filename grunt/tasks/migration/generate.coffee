###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
dot = require('dot')
fs = require('fs')

module.exports = (grunt) ->
  migration = require("#{grunt.config.get('basePath')}/lib/sails-migrations/migration")
  grunt.registerTask("migration:generate", "generate a migration file", ()->
    gakeDir = grunt.config.get('gake').tasksDir
    generateTemplate = "#{grunt.config.get('basePath')}/#{gakeDir}/migration/templates"

    migrationFullname = migration.generateMigration(grunt.option('name'))
    migrationPath = "./migrations/#{migrationFullname}.js"

    templates = dot.process(path: generateTemplate)
    migrationContent = templates.migration(username: "moshe", creationDate: "")
    console.log(migrationContent)

    fs.writeFileSync(migrationPath, migrationContent)
  )
