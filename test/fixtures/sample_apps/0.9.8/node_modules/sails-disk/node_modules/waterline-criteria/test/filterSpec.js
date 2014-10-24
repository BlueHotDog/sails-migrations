var wc = require('../'),
  assert = require('assert'),

  /**
   * 
   * @param  {[type]} operators [description]
   * @param  {[type]} values    stuff to search
   * @param  {[type]} test      [description]
   * @param  {[type]} expect    [description]
   * @return {[type]}           [description]
   */
  expectMatches = function (operators, values, test, expect) {
    var transforms = [function (x) { return x; }, function (x) { return x.toString(); }];
    for (var i = 0; i < operators.length; i++) {
      var operator = operators[i];
      for (var j = 0; j < transforms.length; j++) {
        var transform = transforms[j];
      };
      for (var k = 0; k < transforms.length; k++) {
        var perm = transforms[k],
          data = [],
          where = {key: {}};

        for (var l = 0; l < values.length; l++) {
          data.push({key: perm(values[l])});
        };

        where.key[operator] = transform(test);
        assert.equal(wc(data, {where: where}).length, expect);
      };
    };
  };


describe('filter criteria', function () {

  it('always matches empty filter', function () {
    var values = [0, 1, 2],
      data = [];

    for (var i = 0; i < values.length; i++) {
      data.push({a: values[i]});
    };

    assert.equal(wc(data, {}).length, 3);
    assert.equal(wc(data, {where: null}).length, 3);
    assert.equal(wc(data, {where: {}}).length, 3);
    assert.equal(wc(data, {where: ''}).length, 3);
  });

  it('matches equal', function () {
    var values = [0, 1, 2],
      data = [];

    for (var i = 0; i < values.length; i++) {
      data.push({a: values[i]});
    };

    assert.equal(wc(data, {where: {a: 1}}).length, 1);
    assert.equal(wc(data, {where: {a: '1'}}).length, 1);
  });

  it('matches not', function () {
    expectMatches(['not', '!'], [0, 1, 2], 1, 2);
  });

  it('matches greater than with trickier digitzz', function () {
    expectMatches(['greaterThan', '>'], [0, 10, 5, 50, -5], 5, 2);
  });
  it('matches greater than', function () {
    expectMatches(['greaterThan', '>'], [0, 1, 2], 1, 1);
  });

  it('matches greater than or equal', function () {
    expectMatches(['greaterThanOrEqual', '>='], [0, 1, 2], 1, 2);
  });

  it('matches less than', function () {
    expectMatches(['lessThan', '<'], [0, 1, 2], 1, 1);
  });

  it('matches less than or equal', function () {
    expectMatches(['lessThanOrEqual', '<='], [0, 1, 2], 1, 2);
  });

  it('matches starts with', function () {
    expectMatches(['startsWith'], ['abc', 'bba', 'ccc', 'bcb'], 'b', 2);
  });

  it('matches ends with', function () {
    expectMatches(['endsWith'], ['abc', 'bbb', 'ccc', 'bcb'], 'b', 2);
  });

  it('matches contains', function () {
    expectMatches(['contains'], ['abc', 'bbb', 'ccc', 'bcb'], 'c', 3);
  });

  it('matches like', function () {
    expectMatches(['like'], ['abc', 'bbb', 'ccc', 'bcb'], '%bc%', 2);
  });

  it('matches or', function () {
    var values = ['abc', 'bcd', 'cde'],
      data = [],
      where = {'or': [{key: {contains: 'a'}}, {key: {startsWith: 'b'}}]};

    for (var i = 0; i < values.length; i++) {
      data.push({key: values[i]});
    };

    assert.equal(wc(data, {where: where}).length, 2);
  });

  it('matches and', function () {
    var values = ['abc', 'bcd', 'cde'],
      data = [],
      where = {'and': [{key: {contains: 'b'}}, {key: {startsWith: 'a'}}]};

    for (var i = 0; i < values.length; i++) {
      data.push({key: values[i]});
    };

    assert.equal(wc(data, {where: where}).length, 1);
  });

  it('matches in array', function () {
    var values = [0, 1, 2],
      data = [];

    for (var i = 0; i < values.length; i++) {
      data.push({key: values[i]});
    };

    assert.equal(wc(data, {where: {key: [0, 1]}}).length, 2);
  });
});