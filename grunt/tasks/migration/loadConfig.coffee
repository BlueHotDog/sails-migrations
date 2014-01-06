###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###

module.exports = (grunt) ->
  grunt.registerTask("migration:loadConfig", "internal task to load all needed configuration", ()->
    gakeDir = grunt.config.get('gake').tasksDir
    grunt.config.set('migration.config', {
      templatesPath: "#{grunt.config.get('basePath')}/#{gakeDir}/migration/templates"
    })
    console.log(grunt.config.data);
  )