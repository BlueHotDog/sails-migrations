module.exports = function (grunt) {
  var config = {
    pkg: grunt.file.exists('package.json') ? grunt.file.readJSON('package.json') : {},
    env: process.env.ENV || 'development',
    basePath: __dirname
   // gake: {
     // configDir: './grunt/config',
      //tasksDir: './grunt/tasks'
   // }
  };

  grunt.registerTask('test', function(){
    var Promise = require('bluebird')
    var exec = Promise.promisify(require('child_process').exec);
    var done = this.async();
    var versions = ['0.9.8', '0.9.16', '0.10-rc8'];
    var promises = versions.map(function(version){
      return exec("SAILS_VERSION=" + version + " mocha test/specs");
    });
    Promise.all(promises).then(function(specs){
      grunt.log.write(specs);
      done();
    });
  });

  grunt.initConfig(config);
  grunt.registerTask('default', []);
};
