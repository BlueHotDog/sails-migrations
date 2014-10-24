module.exports = function (grunt) {
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-text-replace');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    clean: {
      bower: ['lib']
    },

    replace: {
      version: {
        src: ['bower.json'],
        dest: 'bower.json',
        replacements: [{
          from: /"version":\s*"[^"]+"/,
          to: '"version": "<%= pkg.version %>"'
        }]
      },
      bower: {
        src: ['index.js'],
        dest: 'lib/waterline-criteria.js',
        replacements: [{
          from: 'module.exports',
          to: 'window.WC'
        }, {
          from: 'require(\'lodash\')',
          to: 'window._'
        }, {
          from: /([\s\S]*)/,
          to: '(function (window) {\n$1\n})(window);\n'
        }]
      }
    },

    uglify: {
      bower: {
        src: 'lib/waterline-criteria.js',
        dest: 'lib/waterline-criteria.min.js'
      }
    }
  });

  grunt.registerTask('default', ['clean', 'replace:version', 'replace:bower', 'uglify']);
};