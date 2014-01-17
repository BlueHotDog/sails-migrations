_ = require('lodash')

Promise = require('bluebird')

class MigrationRunner
#============================PRIVATE========================================
  executeMigrationWithPromise = (func, migration, adapter, cb) ->
    result = func.call(migration, adapter)
    if result && _.isFunction(result.then)
      result.then((=>
        #adding a null first argument
        args = Array::slice.call(arguments, 0)
        args.unshift(null)
        cb.apply(@, args)
      ), cb).catch(cb)
    else
      errorText = """
        Your function is weird,
        It should either accept a cb as a last param or return a promise - but it does neither.
        """
      cb(new Error(errorText))

  runMigration = (direction, migration, adapter, cb) ->
    func = migration[direction]
    funcLength = func.length
    switch funcLength
      when 1 #promise path
        executeMigrationWithPromise(func, migration, adapter, cb)
      when 2 #regular callback path
        funcWithPromise = Promise.promisify(func)
        executeMigrationWithPromise(funcWithPromise, migration, adapter, cb)
      else #huh?
        cb(new Error("Down function should receive either 1, 2 parameters but expected #{funcLength}"))

  validateMigrationData = (migrationData)->
    if _.isNull(migrationData.version) || _.isNull(migrationData.name) || _.isNull(migrationData.path)
      throw new Error("migrationData supplied should contain the following, non empty, attributes: version:\t#{migrationData.version}, name:\t#{migrationData.name},path:\t#{migrationData.path}")

#===========================PUBLIC===========================================
  constructor: (@migrationData)->
    validateMigrationData(@migrationData)
    @

  up: (adapter, cb)->
    migration = @requireMigration()
    runMigration('up', migration, adapter, cb)

  down: (adapter, cb)->
    migration = @requireMigration()
    runMigration('down', migration, adapter, cb)

  requireMigration: ->
    require(@migrationData.path)

  version: ->
    @migrationData.version

  name: ->
    @migrationData.name

  path: ->
    @migrationData.path

  migrate: (adapter, direction, cb)->
    @[direction](adapter, cb)



module.exports = MigrationRunner
