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

## <a id="contact_form"></a>Adapter API
-  **define**: (tableName, definition, cb) - Defines a new table
	- **tableName** - Table name to create
	- **definition** - Definition is same as the attributes given to sails model
	- **cb** - called with err,schema
	- **example** - 
		```
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
	- **example** - ```adapter.drop('myTable', done)```
- **addAttribute**: (tableName, attrName, attrDef, cb) - adds a column to an existing table
	- **tableName** - Table name to which to add the column
	- **attrName** - Name of the attribute to add
	- **
- **removeAttribute**: (tableName, attrName, cb)
- **query**: (query, data, cb)
- **describe**: (tableName, cb)

## TODO

v0.0.2
- [ ] waterline should support database drop/create
- [ ] sails should have a configuration object
- [ ] VERBOSE mode in tasks

v0.0.1
- [x] Create a db:status task
- [x] Create a db:migrate task, support target version
- [x] Create a db:rollback task, support steps
- [x] Create task db:create
- [x] Create task db:drop
- [ ] Load_config task - Make sure the modulesPath is correct for non test environments.
- [ ] add supports for transactions
- [ ] VERBOSE mode in tasks
