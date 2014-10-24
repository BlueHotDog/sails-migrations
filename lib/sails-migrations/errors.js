const util = require('util');

function DatabaseAlreadyExists(message, config) {
  Error.call(this);
  Error.captureStackTrace(this, arguments.callee);
  this.message = message;
  this.config = config;
}

util.inherits(DatabaseAlreadyExists, Error);

function MigrationsFolderDoesNotExists(message, config) {
  Error.call(this);
  Error.captureStackTrace(this, arguments.callee);
  this.message = message;
  this.config = config;
}

util.inherits(MigrationsFolderDoesNotExists, Error);


exports.DatabaseAlreadyExists = DatabaseAlreadyExists;
exports.MigrationsFolderDoesNotExists = MigrationsFolderDoesNotExists;