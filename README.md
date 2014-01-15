# sails-migrations

Sails-Migration provides an easy way to manage database migrations, much like rails does.
This means you can have a fine-grain control over your schema/data transformations between versions.

## Content

- installing
- creating a migration
- working with migration
 

## Installing:

Sails-Migrations only dependencies is sails, so it should be only used within a sails project
To install either run:

```bash
npm install --save sails-migrations
```
or add sails-migrations to your package json and run 
```bash
npm install
```

## Initializing your database

Before running any migrations, you need to verify your database exists, you can simply do that by running:
```bash
grunt db:create
```

## Creating a migration:

To create a new migration, simply run:
```
grunt migration:generate --name="my migration"
```
This should create a new filed within the db/migrations folder called [YYYYMMDDHHMMSS]\_my\_migration.js

sails-migrations uses the timestamp to determine both the order of the migrations and which
migrations were run.


## Working with migrations

A migration constitutes of two parts:

- up: determines what should be performed when you want to forward your database one version
- down: should be the exact reverse of the up method, so for example, if on the up phase you created a table, the down phase should delete that table.

Each phase(up/down) should receive two parameters: 

1. adapter - A thin wrapper around Sails adapter to provide better, more functional way, of working with migrations, see [Adapter](#adapter) for more info
2. done - call this once the migration is done

## Example of a basic migration

```javascript
/*
* Sails migration
* Created at 25/01/1985
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
	

## TODO

- [ ] Add supports for transactions
- [ ] VERBOSE mode in tasks
- [ ] Support synchronous migrations - i.e dont force migration functions to accept done
- [ ] Support migrations that use promises instead of cb
