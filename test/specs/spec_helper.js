process.env.NODE_ENV = "test"
chai = require('chai')
GLOBAL.rek = function(file) {
  return require(__dirname + "/../../" + file)
};

process.on('uncaughtException', console.log.bind(console));

GLOBAL.assert = require('assert');
GLOBAL._ = require('lodash');
GLOBAL.expect = chai.expect;