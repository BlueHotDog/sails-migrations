/**
 * Module dependencies
 */

var util = require('util');
var _ = require('lodash');
var rules = require('./rules');
var errorFactory = require('./errorFactory');

// var JSValidationError

// Exposes `matchType` as `deepMatchType`.
module.exports = deepMatchType;


var RESERVED_KEYS = {
  $validate: '$validate',
  $message: '$message'
};

// Max depth value
var MAX_DEPTH = 50;



/**
 * Match a complex collection or model against a schema
 *
 * @param {?} data
 * @param {?} ruleset
 * @param {Numeric} depth
 * @param {String} keyName
 * @param {String} customMessage
 *                   (optional)
 * 
 * @returns a list of errors (or an empty list if no errors were found)
 */

function deepMatchType(data, ruleset, depth, keyName, customMessage) {

  var self = this;

  // Prevent infinite recursion
  depth = depth || 0;
  if (depth > MAX_DEPTH) {
    return [
      new Error({ message: 'Exceeded MAX_DEPTH when validating object.  Maybe it\'s recursively referencing itself?'})
    ];
  }

  // (1) Base case - primitive
  // ----------------------------------------------------
  // If ruleset is not an object or array, use the provided function to validate
  if (!_.isObject(ruleset)) {
    return matchType.call(self, data, ruleset, keyName, customMessage);
  }


  // (2) Recursive case - Array
  // ----------------------------------------------------
  // If this is a schema rule, check each item in the data collection
  else if (_.isArray(ruleset)) {
    if (ruleset.length !== 0) {
      if (ruleset.length > 1) {
        return [
          new Error({ message: '[] (or schema) rules must contain exactly one item.'})
        ];
      }

      // Handle plurals (arrays with a schema rule)
      // Match each object in data array against ruleset until error is detected
      return _.reduce(data, function getErrors(errors, datum) {
        errors = errors.concat(deepMatchType.call(self, datum, ruleset[0], depth + 1, keyName, customMessage));
        return errors;
      }, []);
    }
    // Leaf rules land here and execute the iterator fn
    else return matchType.call(self, data, ruleset, keyName, customMessage);
  }

  // (3) Recursive case - POJO
  // ----------------------------------------------------
  // If the current rule is an object, check each key
  else {

    // Note:
    // 
    // We take advantage of a couple of preconditions at this point:
    // (a) ruleset must be an Object
    // (b) ruleset must NOT be an Array


    //  *** Check for special reserved keys ***

    // { $message: '...' } specified as data type
    // uses supplied message instead of the default
    var _customMessage = ruleset[RESERVED_KEYS.$message];

    // { $validate: {...} } specified as data type
    // runs a sub-validation (recursive)
    var subValidation = ruleset[RESERVED_KEYS.$validate];

    // Don't allow a `$message` without a `$validate`
    if (_customMessage) {
      if (!subValidation) {
        return [{
          code: 'E_USAGE',
          status: 500,
          $message: _customMessage,
          property: keyName,
          message: 'Custom messages ($message) require a subvalidation - please specify a `$validate` option on `'+keyName+'`'
        }];
      }
      else {
        // Use the specified message as the `customMessage`
        customMessage = _customMessage;
      }
    }

    // Execute subvalidation rules
    if (subValidation) {
      if (!subValidation.type) {
        return [
          new Error({message: 'Sub-validation rules (i.e. using $validate) other than `type` are not currently supported'})
        ];
      }

      return deepMatchType.call(self, data, subValidation.type, depth+1, keyName, customMessage);
    }
    


    

    // Don't treat empty object as a ruleset
    // Instead, treat it as 'object'
    if (_.keys(ruleset).length === 0) {
      return matchType.call(self, data, ruleset, keyName, customMessage);
    } else {
      // Iterate through rules in dictionary until error is detected
      return _.reduce(ruleset, function(errors, subRule, key) {

        // Prevent throwing when encountering unexpectedly "shallow" data
        // (instead- this should be pushed as an error where "undefined" is
        // not of the expected type: "object")
        if (!_.isObject(data)) {
          return errors.concat(errorFactory(data, 'object', key, customMessage));
        } else {
          return errors.concat(deepMatchType.call(self, data[key], ruleset[key], depth + 1, key, customMessage));
        }
      }, []);
    }
  }
}



/**
 * `matchType()`
 * 
 * Return whether a piece of data matches a rule
 *
 * @param {?} datum
 * @param {Array|Object|String|Regexp} ruleName
 * @param {String} keyName
 * @param {String} customMessage
 *                      (optional)
 *
 * @returns a list of errors, or an empty list in the absense of them
 * @api private
 */

function matchType(datum, ruleName, keyName, customMessage) {

  var self = this;

  try {
    var rule;
    var outcome;

    // Determine rule
    if (_.isEqual(ruleName, [])) {
      // [] specified as data type checks for an array
      rule = _.isArray;
    }
    else if (_.isEqual(ruleName, {})) {
      // {} specified as data type checks for any object
      rule = _.isObject;
    }
    else if (_.isRegExp(ruleName)) {
      // Allow regexes to be used
      rule = function(x) {
        // If argument to regex rule is not a string,
        // fail on 'string' validation
        if (!_.isString(x)) {
          rule = rules['string'];
        } else x.match.call(self, ruleName);
      };
    }
    // Lookup rule
    else rule = rules[ruleName];


    // Determine outcome
    if (!rule) {
      return [
        new Error({message:'Unknown rule: ' + ruleName})
      ];
    }
    else outcome = rule.call(self, datum);

    // If validation failed, return an error
    if (!outcome) {
      return errorFactory(datum, ruleName, keyName, customMessage);
    }

    // If everything is ok, return an empty list
    else return [];
  }
  catch (e) {
    return errorFactory(datum, ruleName, keyName, customMessage);
  }

}

