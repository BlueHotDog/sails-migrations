###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
path = require('path')
_ = require('lodash')
module.exports = (grunt) ->
  grunt.registerTask('db:status:validateTableExists', ()->
    done = @async()
    @requires('db:loadConfig')
    @requiresConfig('migration.config')

    config = grunt.config.get('migration.config')
    SchemaMigration = grunt.helpers.loadLibModule("schema_migration")

    SchemaMigration.getInstance(config.defaultAdapter, (err, Model)->
      grunt.log.writeln("Checking if #{SchemaMigration::tableName} exists")
      Model.describe((err, attributes)->
        return grunt.fail.fatal(err) if err
        return grunt.fail.fatal("#{SchemaMigration::tableName} does not exists") unless attributes
        done()
      )
    )
  )
  grunt.registerTask('db:statusTask', 'checks the status of the migrations', ()->
    done = @async()
    @requires('db:loadConfig')
    @requires('db:status:validateTableExists')
    @requiresConfig('migration.config')

    config = grunt.config.get('migration.config')
    SchemaMigration = grunt.helpers.loadLibModule("schema_migration")
    MigrationPath = grunt.helpers.loadLibModule("migration_path")
    fileList = []

    SchemaMigration.getInstance(config.defaultAdapter, (err, Model)->
      Model.find().done((err, dbMigrations)->
        return grunt.fail.fatal(err) if err

        appliedMigrations = {}
        _(dbMigrations).forEach((dbMigration)->
          appliedMigrations[dbMigration.version] = true
        )

        MigrationPath.allMigrationFilesParsed(grunt.config.get("migration.config.migrationOutDir"), (err, migrationFiles)->
          # for each file, we see if we applied it or not, if we did, then it is in up state, else it's in down
          _(migrationFiles).forEach((fileData)->
            if (appliedMigrations[fileData.version])
              status = "up"
            else
              status = "down"

            delete appliedMigrations[fileData.version]
            fileList.push([status, "#{fileData.version}", "#{fileData.path}"])
          )
          # checking a weird case where we recorded a migration on the db but a file is missing
          _.map(appliedMigrations,(applied, version)->
            fileList.push(["up", version, '********** NO FILE **********'])
          )
          grunt.log.subhead(grunt.log.table([10, 20, 40], ["status", "version", "filename"]))
          _.forEach(fileList, (texts) ->
            grunt.log.writelns(grunt.log.table([10, 20, 40], texts))
          )
          done()
        )
      )
    )
  )

  grunt.registerTask('db:status', 'Display status of migrations', [
    'db:loadConfig',
    'db:status:validateTableExists',
    'db:statusTask'
  ])

