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

## Example apps

You can checkout some [example Sails apps](https://github.com/BlueHotDog/sails-migrations/tree/master/samples).

## Commands

For a list of commands, simply run sails-migrations from your command prompt.


## Working with migrations

For a more detailed documentation, please refer to http://knexjs.org/
A migration constitutes of two parts:

- `up`: determines what should be performed when you want to forward your database to this version.
- `down`: should be the exact reverse of the up method, so, for example, if on the up phase you created a table, the down phase should delete that table.
