path = require('path')
_ = require('lodash')

module.exports = (grunt) ->
  grunt.helpers ||= {}
  helpers = {
    loadLibModule: (name)->
      fileName = path.join(grunt.config.get('migration.config.migrationLibPath'), name)
      require(fileName)
  }
  _.extend(grunt.helpers, helpers)
