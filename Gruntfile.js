module.exports = function (grunt) {
  var config = {
    pkg: grunt.file.exists('package.json') ? grunt.file.readJSON('package.json') : {},
    env: process.env.ENV || 'development',
    basePath: __dirname,
    gake: {
      configDir: './grunt/config',
      tasksDir: './grunt/tasks'
    }
  };

  grunt.initConfig(config);
  grunt.loadNpmTasks('gake');
  grunt.loadNpmTasks('sails-migrations');
};
