var Waterline = require('../../../lib/waterline'),
    assert = require('assert');

describe('Collection Query', function() {

  describe('.create()', function() {

    describe.skip('with children associations', function() {
      var query, fooValues = [];

      before(function(done) {

        var waterline = new Waterline();
        var collections = {};


        collections.user = Waterline.Collection.extend({
          identity: 'user',
          connection: 'foo',
          attributes: {
            name: {
              type: 'string'
            },
            cars: {
              collection: 'car',
              via: 'drivers'
            }
          }
        });

        collections.car = Waterline.Collection.extend({
          identity: 'car',
          connection: 'foo',
          attributes: {
            make: {
              type: 'string'
            },
            drivers: {
              collection: 'user',
              via: 'cars',
              dominant: true
            }
          }
        });

        waterline.loadCollection(collections.user);
        waterline.loadCollection(collections.car);

        // Fixture Adapter Def
        // var adapterDef = { create: function(con, col, values, cb) { return cb(null, values); }};

        var i = 1;

        var adapterDef = {
          find: function(con, col, criteria, cb) { return cb(null, fooValues); },
          create: function(con, col, values, cb) {
            values.id = i;
            i++;
            fooValues.push(values);
            return cb(null, values);
          },
          update: function(con, col, criteria, values, cb) { return cb(null, values); }
        };


        var connections = {
          'foo': {
            adapter: 'foobar'
          }
        };

        waterline.initialize({ adapters: { foobar: adapterDef }, connections: connections }, function(err, colls) {
          if(err) done(err);
          query = colls.collections.user;
          done();
        });
      });

      it.skip('create associated values', function(done) {

        var data = [
          { make: 'porsche' },
          { make: 'honda' },
          { make: 'ford' }
        ];

        query.create({ name: 'foo', cars: data }, function(err, status) {
          console.log(err);
          if(err) return done(err);

          console.log(fooValues)
          assert(fooValues.length === 2);
          assert(fooValues[0] === 'foo');
          assert(fooValues[1] === 'bar');

          done();
        });
      });

    });

  });
});
