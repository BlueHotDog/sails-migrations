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


    MigratorHelper = grunt.helpers.loadLibModule('migrator_helper')
    migrator = MigratorHelper.getMigrator(adapter, {
      path: migrationsPath
    })

    options = {
      logging: grunt.log.oklns
      method: 'up'
    }
    options.to = targetVersion if targetVersion?
    migrator.migrate(options).success(->
      done()
    ).error((error)->
      console.dir(error)
      grunt.fail.fatal("Failed to migrate,\terror: #{error}")
      done(error)
    )
  )

  grunt.registerTask('db:rollbackTask', 'rollback', ->
    done = @async()
    @requires('db:loadConfig')
    @requiresConfig('migration.config')
    config = grunt.config.get('migration.config')

    migrationsPath = config.migrationOutDir
    adapter = config.defaultAdapter
    targetVersion = grunt.option('version')


    MigratorHelper = grunt.helpers.loadLibModule('migrator_helper')
    migrator = MigratorHelper.getMigrator(adapter, {
      path: migrationsPath
    })

    options = {
      logging: grunt.log.oklns
      method: 'down'
    }
    options.to = targetVersion if targetVersion?
    migrator.migrate(options).success(->
      done()
    ).error((error)->
      throw error
    )
  )

  grunt.registerTask('db:rollback', ['db:loadConfig', 'db:rollbackTask'])
  grunt.registerTask('db:migrate', ['db:loadConfig', 'db:migrateTask'])

