# sails-migrations

[![NPM version](https://badge.fury.io/js/sails-migrations.png)](http://badge.fury.io/js/sails-migrations)
[![Dependency Status](https://gemnasium.com/BlueHotDog/sails-migrations.png)](https://gemnasium.com/BlueHotDog/sails-migrations)
[![Code Climate](https://codeclimate.com/github/BlueHotDog/sails-migrations.png)](https://codeclimate.com/github/BlueHotDog/sails-migrations)
[![Build Status](https://travis-ci.org/BlueHotDog/sails-migrations.png?branch=master)](https://travis-ci.org/BlueHotDog/sails-migrations)

sails-migrations provides an easy way to manage database migrations with sails, based on the amazing https://github.com/tgriesser/knex lib.
This means you can have fine-grained control over your schema/data transformations between versions.

## Supported sails versions:

sails-migrations supports sails versions 0.9X up to 0.10.5, for both MySQL & PostgreSQL.

Please let us know if you encounter any problem working with sails-migrations by
opening an issue.

As of version 2.0 we've moved to using knex schema builder.

**NOTE**

- sails-migrations up until (including) 0.1 supported Sails versions 0.9 & 0.10RC8

- When upgrading to 2.0, notice that you'll need to change your old migrations code to work with knex instead of waterline.

## What db migrations are and how/when to use them:

DB migrations allows you to change your database schema/data in a controlled way by making small atomic/ordered data to your DB, for a better answer, read [this](https://github.com/phusion/passenger-docker)

## Installing:

First run

```bash
npm install -g sails-migrations
```

this will install the global CLI sails-migrations.

Next you'll need to install sails-migrations within the project you would like to work on:

```bash
npm install --save sails-migrations
```
## Usage

Fairly simple, there are a few basic commands
- `db:drop` - Just as the name suggests, reads your sails config, and *DROPS* the db. use with care.
- `db:create` - Same but different, creates the db you specified in your sails config.
- `generate <name>` - Generate a new blank migrations file, after you run this command, you need to open the new file, which by default is saved to `\db\migrations\`, after you run this command, you should open this file, and put your migration information. for the migration syntex, please refer to the [Knex](https://github.com/tgriesser/knex) documentation
- `migrate` - Runs all the not-yet-runned migrations from the last run of migrate, all of those migrations are saved as a `batch`.
- `rollback` - Runs the revert function on each migration in the last `batch`.
- `status` - Prints a nice table of all the committed/uncommitted migrations.

## Example apps

You can checkout some [example Sails apps](https://github.com/BlueHotDog/sails-migrations/tree/master/test/fixtures/sample_apps).

## Commands

For a list of commands, simply run sails-migrations from your command prompt.


## Working with migrations

For a more detailed documentation, please refer to http://knexjs.org/
A migration constitutes of two parts:

- `up`: determines what should be performed when you want to forward your database to this version.
- `down`: should be the exact reverse of the up method, so, for example, if on the up phase you created a table, the down phase should delete that table.
