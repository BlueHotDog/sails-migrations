Promise = require("bluebird")
_ = require('lodash')
path = require('path')
glob = require('glob')
moment = require('moment')
_s = require('underscore.string')

class Migration
  @allMigrationsFiles: (paths = @migrationsPaths(), cb)->
    paths = _.toArray(paths)
    _(paths).map((path) ->
      glob.sync("#{path}/**/[0-9]*_*.{coffee,js}", {})
    ).flatten().value()

  @latestMigration: (migrations)->
    migrations ||= [];
    _(migrations).map(@parseMigrationFileName).max('version')

  @parseMigrationFileName: (file)->
    regex = /([0-9]+)_([_a-z0-9]*)\.(coffee|js)/
    file.match(regex)
    {
      version: _.parseInt(result[1], 10)
      name: result[2]
    }

  @generateMigration: (name)->
    migrationName = _s.underscored(name)
    migrationNumber = @nextMigrationNumber()
    "#{migrationNumber}_#{migrationName}"

  @nextMigrationNumber: -> moment().format('YYYYMMDDHHmmss')

  @migrations: (paths, cb)->
    paths = _.toArray(paths)
    files = []
    Promise
    .map(paths, (path) ->
        "#{path}/**/[0-9]*_*.{coffee,js}")
    .map((path)->
        glob(path, {}))
    .map((files)->
        console.log(files))

  @basePath: ->
    '/vagrant/sails-migrations/test/'

  @migrationsPaths: ->
    ['/vagrant/sails-migrations/test/db/migrate']


module.exports = Migration
