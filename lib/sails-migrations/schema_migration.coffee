class SchemaMigration
  @tableName: ->
    "sails_schema_migrations"

  @indexName: ->
    "unique_schema_migrations"

  @createTable: ->
