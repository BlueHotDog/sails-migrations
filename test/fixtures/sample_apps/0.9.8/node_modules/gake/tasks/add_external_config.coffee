gake = require('../lib/gake.coffee')

class AddExternalConfig
  @register: (grunt) ->
    (new gake(grunt)).use()


module.exports = AddExternalConfig.register.bind(AddExternalConfig)