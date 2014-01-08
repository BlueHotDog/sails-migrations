LOCAL_HOSTS = ['127.0.0.1', 'localhost']
class DatabaseTasks
  create: (adapter)->
    console.log(adapter)

  migrations_paths: ->
    #TODO: sails should have something similar to rails Rails.application.paths['db/migrate'].to_a
    @migrations_paths ||= 'db/migrate'

  drop: ->
    #TODO: waterline needs to add support for dropping a database



module.exports = DatabaseTasks