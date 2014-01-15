###
  Auto generated task by Gake
  Please visit http://gruntjs.com/ to learn more about how to work with grunt tasks
###
path = require('path')
_ = require('lodash')

module.exports = (grunt, done) ->
  grunt.registerTask('db:migrateTask', 'migrate', ->
    done = @async()
    @requires('db:loadConfig')
    @requiresConfig('migration.config')
    config = grunt.config.get('migration.config')

    migrationsPath = config.migrationOutDir
    adapter = config.defaultAdapter
    targetVersion = grunt.option('version')

    Migrator = grunt.helpers.loadLibModule('migrator')
    Migrator.migrate(adapter, migrationsPath, targetVersion, (err, migrations, failedMigration)->
      _.each(migrations, (migration)->
        grunt.log.oklns("Migrated #{migration.name()} #{migration.version()}")
      )
      if failedMigration
        grunt.fail.fatal("Failed to migrate #{failedMigration.name()} #{failedMigration.version()} error: #{err}")
      done()
    )
  )

  grunt.registerTask('db:rollbackTask', 'rollback', ->
    done = @async()
    @requires('db:loadConfig')
    @requiresConfig('migration.config')
    config = grunt.config.get('migration.config')

    migrationsPath = config.migrationOutDir
    adapter = config.defaultAdapter
    steps = grunt.option('steps')

    Migrator = grunt.helpers.loadLibModule('migrator')
    Migrator.rollback(adapter, migrationsPath, steps, (err, migrations, failedMigration)->
      _.each(migrations, (migration)->
        grunt.log.oklns("Rolling back #{migration.name()} #{migration.version()}")
      )
      if failedMigration
        grunt.fail.fatal("Failed to rollback #{failedMigration.name()} #{failedMigration.version()} error: #{err}")
      done()
    )
  )

  grunt.registerTask('db:rollback', ['db:loadConfig', 'db:rollbackTask'])
  grunt.registerTask('db:migrate', ['db:loadConfig', 'db:migrateTask'])

