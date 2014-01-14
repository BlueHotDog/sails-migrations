# sails-migrations

Sails-Migration provides an easy way to manage database migrations, much like rails does.
This means you can have a fine-grain control over your schema/data transformations between versions.

## Installing:

Sails-Migrations only dependencies is sails, so it should be only used within a sails project
To install either run:

```bash
npm install --save sails-migrations
```
or add sails-migrations to your package json and run ```npm install```

## Creating a migration:

To create a new migration, simply run:
```
grunt migration:generate --name="my migration"
```
This should create a new filed within the db/migrations folder called [YYYYMMDDHHMMSS]_my_migration.js

sails-migrations uses the timestamp to determine both the order of the migrations and which
migrations were run.


## Working with migrations

A migration constitutes of two parts:

- up: determines what should be performed when you want to forward your database one version
- down: should be the exact reverse of the up method, so for example, if on the up phase you created a table, the down phase should delete that table.

Each phase(up/down) should receive two parameters: 

1. adapter - A thin wrapper around Sails adapter to provide better, more functional way, of working with migrations, see [Adapter][adapter] for more info
2. done
[Link back to H2](#adapter)

## Example of a basic migration

```javascript
/*
* Sails migration
* Created by BlueHotDog at 25/01/1985
* */

exports.up = function(adapter, done) {
	
	done();
};

exports.down = function(adapter, done) {
  done();
};

```

{#adapter}
## Adapter API
## TODO

- [ ] waterline should support database drop/create
- [ ] add supports for transactions
- [ ] VERBOSE mode in tasks
