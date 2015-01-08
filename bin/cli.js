#!/usr/bin/env node

'use strict';

var Liftoff = require('liftoff');
var Promise = require('bluebird');
var args = require('optimist').argv;
var chalk = require('chalk');
var commander = require('commander');
var cliPkg = require('../package');
var tildify = require('tildify');
var Table = require('cli-table');
var errors = require('../lib/sails-migrations/errors');
var _ = require('lodash');

var cli = new Liftoff({
  name: 'sails-migrations',
  file: 'migrationsFile',
  extensions: require('interpret').jsVariants
});


function exitWithError(text) {
  if (text instanceof Error) {
    console.error(chalk.red(text.stack));
  } else {
    console.error(chalk.red(text));
  }
  process.exit(1);
}

function exitSuccessfully(text) {
  console.log(text);
  process.exit(0);
}


function initSailsMigrations(env) {
  if (!env.modulePath) {
    console.log(chalk.red('No local sails_migrations install found in:'), chalk.magenta(tildify(env.cwd)));
    exitWithError('Try running: `npm install sails-migrations`');
  }

  if (process.cwd() !== env.cwd) {
    process.chdir(env.cwd);
    console.log('Working directory changed to', chalk.magenta(tildify(env.cwd)));
  }

  return require(env.modulePath);
}

var invoke = function (env) {
  var pending, filetypes = ['js', 'coffee'];

  commander
    .version(
      chalk.blue('sails_migrations CLI version: ', chalk.green(cliPkg.version)) + '\n' +
      chalk.blue('Local sails_migrations version: ', chalk.green(env.modulePackage.version)) + '\n'
  )
    .option('--cwd [path]', 'Specify the working directory.')
    .option('--env [name]', 'environment, default: process.env.NODE_ENV || development');


  commander
    .command('generate <name>')
    .description('        Create a named migration file.')
    .option('-x [' + filetypes.join('|') + ']', 'Specify the stub extension (default js)')
    .action(function (name) {
      var ext = (args.x || 'js').toLowerCase();
      pending = initSailsMigrations(env)
        .generate(name, {extension: ext})
        .then(function (name) {
          exitSuccessfully(chalk.green('Created Migration: ' + name));
        }).catch(exitWithError);
    });

  commander
    .command('migrate')
    .description('        Run all migrations that have not yet been run.')
    .action(function () {
      pending = initSailsMigrations(env)
        .migrate()
        .spread(function (batchNo, log) {
          if (log.length === 0) {
            exitSuccessfully(chalk.cyan('Already up to date'));
          }
          exitSuccessfully(chalk.green('Batch ' + batchNo + ' run: ' + log.length + ' migrations \n' + chalk.cyan(log.join('\n'))));
        })
        .catch(exitWithError);
    });

  commander
    .command('rollback')
    .description('        Rollback the last set of migrations performed.')
    .action(function () {
      pending = initSailsMigrations(env)
        .rollback()
        .spread(function (batchNo, log) {
          if (log.length === 0) {
            exitSuccessfully(chalk.cyan('Already at the base migration'));
          }
          exitSuccessfully(chalk.green('Batch ' + batchNo + ' rolled back: ' + log.length + ' migrations \n') + chalk.cyan(log.join('\n')));
        })
        .catch(exitWithError);
    });

  commander
    .command('db:create')
    .description('        Create the database')
    .action(function () {
      pending = initSailsMigrations(env)
        .createDatabase()
        .then(function (result) {
          exitSuccessfully(chalk.green('successfully created database: ' + chalk.blue(result.connection.database) + ' on host: ' + chalk.blue(result.connection.host)));
        }).catch(exitWithError);
    });

  commander
    .command('db:drop')
    .description('        Drops the database')
    .action(function () {
      pending = initSailsMigrations(env)
        .dropDatabase()
        .then(function (result) {
          exitSuccessfully(chalk.green('successfully dropped database: ' + chalk.blue(result.connection.database) + ' on host: ' + chalk.blue(result.connection.host)))
        }).catch(exitWithError);
    });

  commander
    .command('status')
    .description('        Nice status table to tickle your fancy')
    .action(function () {
      pending = initSailsMigrations(env)
        .status()
        .spread(function (all, completed) {
          all = all || [];
          var table = new Table({
            head: [chalk.blue.bold('Migration name'), chalk.blue.bold('Did run?'), chalk.blue.bold('Batch no.')]
          });

          all.forEach(function (migrationName) {
            var completedMigration = _.find(completed, {name: migrationName});
            var didRun = completedMigration ? true : false;
            var batchNo = completedMigration ? completedMigration.batch : '';
            table.push([chalk.white(migrationName), didRun ? chalk.green('true') : chalk.red('false'), batchNo])
          });

          exitSuccessfully(table.toString());
        }).catch(exitWithError);
    });

  commander
    .command('current_version')
    .description('        View the current version for the migration.')
    .action(function () {
      pending = initSailsMigrations(env)
        .currentVersion()
        .then(function (version) {
          exitSuccessfully(chalk.green('Current Version: ') + chalk.blue(version));
        }).catch(exitWithError);
    });


  commander.parse(process.argv);

  Promise.resolve(pending).then(function () {
    commander.help();
  });
};

cli.on('require', function (name) {
  console.log('Requiring external module', chalk.magenta(name));
});

cli.on('requireFail', function (name) {
  console.log(chalk.red('Failed to load external module'), chalk.magenta(name));
});

cli.launch({
  cwd: args.cwd,
  configPath: args.sailsMigrationFile,
  require: args.require,
  completion: args.completion
}, invoke);
