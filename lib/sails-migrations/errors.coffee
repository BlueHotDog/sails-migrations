module.exports.DatabaseAlreadyExists = class DatabaseAlreadyExists extends Error
  constructor: (message, adapter)->
    @name = 'DatabaseAlreadyExists'
    @message = message
    @adapter = adapter
