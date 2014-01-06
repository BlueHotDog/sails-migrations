###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
path = require('path')

module.exports = (grunt) ->
  grunt.registerTask("migration:loadConfig", "internal task to load all needed configuration", ()->
    gakeDir = grunt.config.get('gake').tasksDir
    grunt.config.set('migration.config', {
      migrationOutDir: path.join("#{grunt.config.get('basePath')}","db","migrations")
      templatesPath: path.join("#{grunt.config.get('basePath')}","#{gakeDir}/migration/templates")
    })
  )