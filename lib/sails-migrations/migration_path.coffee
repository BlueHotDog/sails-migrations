Promise = require("bluebird")
_ = require('lodash')
path = require('path')
glob = require('glob')
moment = require('moment')
_s = require('underscore.string')

class Migration

  @allMigrationsFiles: (paths = @migrationsPaths(), cb) ->
    paths = [paths] unless _.isArray(paths)
    result = _(paths).map((path) ->
      glob.sync("#{path}/**/[0-9]*_*.{coffee,js}", {})
    ).flatten().value()

    cb(null, result)

  @allMigrationFilesParsed: (paths = @migrationsPaths(), cb) ->
    @allMigrationsFiles(paths, (err, values)=>
      parsed = _(values).map(@parseMigrationFileName).compact().value()
      cb(null, parsed)
    )

  @latestMigration: (migrations)->
    migrations ||= [];
    _(migrations).map(@parseMigrationFileName).max('version').value()

  @parseMigrationFileName: (file)->
    regex = /([0-9]+)_([_a-z0-9]*)\.(coffee|js)/
    result = file.match(regex)
    {
      version: _.parseInt(result[1], 10)
      name: result[2]
      path: file
    }

  @generateMigrationName: (name)->
    migrationName = _s.underscored(name)
    migrationNumber = @nextMigrationNumber()
    "#{migrationNumber}_#{migrationName}"

  @nextMigrationNumber: -> moment().format('YYYYMMDDHHmmss')

  @basePath: ->
    '/vagrant/sails-migrations/test/'

  @migrationsPaths: ->
    ['/vagrant/sails-migrations/test/db/migrate']


module.exports = Migration
