class CustomAssertions
  @assertTableColumnCount: (adapterWrapper, tableName, expectedColumns, cb)->
    adapterWrapper.describe(tableName, (err, definition)->
      return cb(err) if err
      definition = {} unless definition
      assert.equal(_.keys(definition).length, expectedColumns)
      cb()
    )

module.exports = CustomAssertions
