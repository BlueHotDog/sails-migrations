###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
path = require('path')

module.exports = (grunt, done) ->
  grunt.registerTask('migration:migrateTask', 'migrate', ()->
    done = @async()
    @requires('migration:loadConfig')
    config = grunt.config.get('migration.config')
    MigrationRunner = require(path.join(config.migrationLibPath, 'migration_runner'))
    Migration = require(path.join(config.migrationLibPath, 'migration'))
    migrationFiles = Migration.allMigrationsFiles([config.migrationOutDir])
    migrationRunner = new MigrationRunner(Migration.latestMigration(migrationFiles))
    migrationRunner.up(config.defaultAdapter, (err, model)->
      console.log('ole!!')
    )
  )

  grunt.registerTask('migration:migrate', ['migration:loadConfig', 'migration:migrateTask'])

