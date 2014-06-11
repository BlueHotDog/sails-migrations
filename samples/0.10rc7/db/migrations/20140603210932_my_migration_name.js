/*
* Sails migration
* Created at 2014-06-03T21:09:32+03:00
* */

var someTableName = "myTable";
module.exports = {
  up: function(migration, DataTypes, done) {
    migration.createTable(
      someTableName,
      {
        id: {
          type: DataTypes.INTEGER,
          primaryKey: true,
          autoIncrement: true
        },
        attr1: DataTypes.STRING,
        attr2: DataTypes.INTEGER,
        attr3: {
          type: DataTypes.BOOLEAN,
          defaultValue: false,
          allowNull: false
        }
      }
    ).complete(done)
  },
  down: function(migration, DataTypes, done) {
    migration.dropTable(someTableName).complete(done)
  }
};