# sails-migrations

[![NPM version](https://badge.fury.io/js/sails-migrations.png)](http://badge.fury.io/js/sails-migrations)
[![Dependency Status](https://gemnasium.com/BlueHotDog/sails-migrations.png)](https://gemnasium.com/BlueHotDog/sails-migrations)
[![Code Climate](https://codeclimate.com/github/BlueHotDog/sails-migrations.png)](https://codeclimate.com/github/BlueHotDog/sails-migrations)

sails-migrations provides an easy way to manage database migrations, much like Rails does.
This means you can have fine-grained control over your schema/data transformations between versions.

## Installing:

sails-migrations' only dependencies are Sails and mysql/postgres (currently) adapters,
To install run:

```bash
npm install --save sails-migrations
```
## Example app

You can checkout an [example Sails](https://github.com/itayadler/sails-migrations-testapp).


## Initializing your database

Before running any migrations, you need to verify your database exists, you can do that by running:

```bash
grunt db:create
```

This should create an empty database with the _sails\_schema\_migrations_  table - which is used to track what migrations were run against this db.

## Working with migrations

A migration constitutes of two parts:

- `up`: determines what should be performed when you want to forward your database to this version.
- `down`: should be the exact reverse of the up method, so, for example, if on the up phase you created a table, the down phase should delete that table.

Each phase (`up`/`down`) will receive two `parameters`:

1. `adapter` - A thin wrapper around Sails adapter to provide better, more functional way, of working with migrations, see [Adapter](#adapter_api) for more info.
2. `done` - callback

## Creating a migration:

To create a new migration, simply run:
```bash
grunt migration:generate --name="my migration name"
```
This should create a new file within the **db/migrations** folder called [YYYYMMDDHHMMSS]\_my\_migration\_name.js

sails-migrations uses the timestamp to determine both the order of the migrations and which migrations were run.

## Example of a basic migration file

```javascript
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

```

## Migration CLI

- ```grunt db:migrate```: By default, runs migrations up to the latest migration available
  - _[--version=]_ - _optional_ - up to which version to run the migrations(inclusive)
- ```grunt db:rollback```: By default, runs the down step of the latest migration executed
  - _[--steps=1]_ - _optional_ How many rollbacks to perform, default is 1
- ```grunt db:drop```: Drops the database
- ```grunt db:create```: Creates an empty database(with the [sails_schema_migrations](#sails_schema_migrations) table)
- ```grunt db:reset```: Drops & Creates the database
- ```grunt db:status```: Prints out the status of each migration in the migration folder

## <a id="adapter_api"></a>Adapter API

-  **define**: (tableName, definition, cb) - Defines a new table
	- **tableName** - Table name to create
	- **definition** - Same as the attributes given to sails model
	- **cb** - called with err,schema
	- **example** -

		```javascript
			definition = {
				first_name: {type: 'STRING'},
				last_name: {type: 'STRING'},
				id: {
					type: 'INTEGER',
					autoIncrement: true,
					defaultsTo: 'AUTO_INCREMENT',
					primaryKey: true
				}
			}
			adapter.define('myTable', definition, function (err, schema) {
				//do something
			})
		```
- **drop**: (tableName, cb) - Drops a table
	- **tableName** - Table name of the table to drop
	- **cb** - called with err,schema
	- **example** -

	```javascript
		adapter.drop('myTable', done)
	```
- **addAttribute**: (tableName, attrName, attrDef, cb) - adds a column to an existing table
	- **tableName** - Table name to which to add the column
	- **attrName** - Name of the attribute to add
	- **attrDef** - Same as in waterline model
	- **example** -

	```javascript
		adapter.addAttribute('myTable', 'phoneNumber', {type:'INTEGER'}, done);
	```
- **removeAttribute**: (tableName, attrName, cb) - removes a column from an existing table
	-  **tableName** - Table name from which to remove the attribute
	-  **attrName** - Attribute to remove
	- **cb** - called with err if any
	- **example** -

	```javascript
		adapter.removeAttribute('myTable', 'phoneNumber', done);
	```
- **query**: (query, data, cb)
	-	**query** - a String query to execute directly against the DB
	-	**data** - used to incorpurate values into the query
	-	**cb**
- **describe**: (tableName, cb) - returns a definition of a table, i.e its schema
	- **tableName** - the table name to describe
	- **cb** called with err,attributes, when schema is a hash of the following format:

	```javascript
		{
			id: {
					type: 'INTEGER',
					autoIncrement: true,
					defaultsTo: 'AUTO_INCREMENT',
					primaryKey: true
				}
		}
	```
