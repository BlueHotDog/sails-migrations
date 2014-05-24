/*
 * Sails migration
 * Created at 25/01/1985
 * */

exports.up = function(adapter, done) {
  adapter.define('tableName', {name: {type: 'STRING'}}, done);
};

exports.down = function(adapter, done) {
  adapter.drop('tableName', done);
};