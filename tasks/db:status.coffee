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

    migrationsPath = config.migrationOutDir
    adapter = config.defaultAdapter

    MigratorHelper = grunt.helpers.loadLibModule('migrator_helper')

    migrator = MigratorHelper.getMigrator(adapter, {
      path: migrationsPath
    })
    metaTableName = 'SequelizeMeta'

    grunt.log.writeln("Checking if #{metaTableName} exists")

    storedDAO = migrator.sequelizeMeta().findAll().success(->
      done()
    ).error(->
      return grunt.fail.fatal("#{metaTableName} does not exists") unless storedDAO
    )
  )
  grunt.registerTask('db:statusTask', 'checks the status of the migrations', ()->
    done = @async()
    @requires('db:loadConfig')
    @requires('db:status:validateTableExists')
    @requiresConfig('migration.config')

    config = grunt.config.get('migration.config')

    MigrationPath = grunt.helpers.loadLibModule("migration_path")
    fileList = []

    migrationsPath = config.migrationOutDir
    adapter = config.defaultAdapter

    MigratorHelper = grunt.helpers.loadLibModule('migrator_helper')

    migrator = MigratorHelper.getMigrator(adapter, {
      path: migrationsPath
    })

    migrator.sequelizeMeta().findAll()
    .error((err)->return grunt.fail.fatal(err) if err)
    .success((dbMigrations)->
        appliedMigrations = {}
        _(dbMigrations).forEach((dbMigration)->
          appliedMigrations[dbMigration.to] = true
        )


        MigrationPath.allMigrationFilesParsed(grunt.config.get("migration.config.migrationOutDir"),
        (err, migrationFiles)->
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
          _.map(appliedMigrations, (applied, version)->
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

  grunt.registerTask('db:status', 'Display status of migrations', [
    'db:loadConfig',
    'db:status:validateTableExists',
    'db:statusTask'
  ])

