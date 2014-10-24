const exec = require('child_process').exec;
const _ = require('lodash');
const errors = require('../errors');

const PG_CLIENT_NAME = 'pg';
const MYSQL_CLIENT_NAME = 'mysql';

function DatabaseTasks() {}


DatabaseTasks.executeQuery = function (config, query, cb) {
  //config.debug = true;
  config.connection.database = undefined; //bug in knex, if you pass a db, it will fail to drop/create a db :-(
  var knex = require('knex')(config);
  knex.raw(query).then(cb, cb)
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
  DatabaseTasks.executeQuery(config, "CREATE DATABASE \"" + config.connection.database + "\"", function (err, stdout, stdin) {
    cb(err, config);
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
  DatabaseTasks.executeQuery(config, "DROP DATABASE \"" + config.connection.database + "\"", function (err, stdout, stdin) {
    cb(err, config);
  });
};

module.exports = DatabaseTasks;
