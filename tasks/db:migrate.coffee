###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
path = require('path')

module.exports = (grunt, done) ->
  grunt.registerTask('db:migrateTask', 'migrate', ()->
    done = @async()
    @requires('migration:loadConfig')
    config = grunt.config.get('migration.config')

    MigrationRunner = grunt.helpers.loadLibModule('migration_runner')
    Migration = grunt.helpers.loadLibModule('migration')

    Migration.allMigrationsFiles([config.migrationOutDir], (err, migrationFiles)->
      migrationRunner = new MigrationRunner(Migration.latestMigration(migrationFiles))
      migrationRunner.up(config.defaultAdapter, (err, model)->
        return grunt.fail.fatal(err) if err
        grunt.log.oklns("Successfully migrated version:\t#{migrationRunner.migrationData.version}")
        done()
      )

    )
  )

  grunt.registerTask('db:migrate', ['migration:loadConfig', 'db:migrateTask'])

