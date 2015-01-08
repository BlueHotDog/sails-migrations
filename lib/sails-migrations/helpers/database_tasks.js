const exec = require('child_process').exec;
const _ = require('lodash');
const errors = require('../errors');

const PG_CLIENT_NAME = 'pg';
const MYSQL_CLIENT_NAME = 'mysql';

function DatabaseTasks() {}


DatabaseTasks.executeQuery = function (config, query, cb) {
  //config.debug = true;
  database = config.connection.database
  config.connection.database = undefined; //bug in knex, if you pass a db, it will fail to drop/create a db :-(
  var knex = require('knex')(config);
  knex.raw(query).pipe(function(){config.connection.database = database}).then(cb, cb)
};

/*
 * config -
 *   client: 'mysql' or 'postgresql'
 *   database: the database name
 *   user: db user
 *   password: db connection password
 *   host: db host
 * */
DatabaseTasks.create = function (config, cb) {
  var database = config.connection.database;
  DatabaseTasks.executeQuery(config, "CREATE DATABASE \"" + database + "\"", function (err, stdout, stdin) {
    config.connection.database = database;
    if (err instanceof Error){
      cb(err, config);
    } else {
      cb(null, config);
    }
  });
};

/*
 * config -
 *   client: 'mysql' or 'postgresql'
 *   database: the database name
 *   user: db user
 *   password: db connection password
 *   host: db host
 * */
DatabaseTasks.drop = function (config, cb) {
  var database = config.connection.database;
  DatabaseTasks.executeQuery(config, "DROP DATABASE \"" + database + "\"", function (err, stdout, stdin) {
    config.connection.database = database;
    if (err instanceof Error){
      cb(err, config);
    } else {
      cb(null, config);
    }
  });
};

module.exports = DatabaseTasks;
