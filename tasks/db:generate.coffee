###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
dot = require('dot')
fs = require('fs')
path = require('path')
moment = require('moment')
mkdirp = require('mkdirp')

module.exports = (grunt) ->
  grunt.registerTask("migration:generateInternalTask", ->
    @requires("db:loadConfig")
    @requiresConfig("migration.config")
    grunt.fail.fatal("The --name parameter is required") unless grunt.option('name')

    config = grunt.config.get('migration.config')

    MigrationPath = require(path.join(config.migrationLibPath, "migration_path"))
    migrationFullname = MigrationPath.generateMigrationName(grunt.option('name'))
    migrationPath = path.join(config.migrationOutDir,"#{migrationFullname}.js")
    mkdirp.sync(config.migrationOutDir) # making sure the migrations outdir directory exists

    # This setting will make sure doT preserves the white spaces in the migration template file.
    dot.templateSettings.strip = false
    templates = dot.process(path: config.templatesPath)
    migrationContent = templates.migration(creationDate:  moment().format())

    fs.writeFileSync(migrationPath, migrationContent)
  )

  grunt.registerTask("migration:generate", "run database migrations", ['db:loadConfig', 'migration:generateInternalTask'])
