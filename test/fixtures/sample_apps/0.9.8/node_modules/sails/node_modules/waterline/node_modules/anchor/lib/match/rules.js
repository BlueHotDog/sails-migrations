/**
 * Module dependencies
 */

var _ = require('lodash');
var validator = require('validator');



/**
 * Type rules
 */

module.exports = {

	'empty'		: _.isEmpty,

	'required'	: function (x) {
		// Transform data to work properly with node validator
		if(!x && x !== 0) x = '';
		else if(typeof x.toString !== 'undefined') x = x.toString();
		else x = '' + x;

		return !validator.isNull(x);
	},

	'notEmpty'	: function (x) {

		// Transform data to work properly with node validator
		if (!x) x = '';
		else if (typeof x.toString !== 'undefined') x = x.toString();
		else x = '' + x;

		return !validator.isNull(x);
	},

	'undefined'	: _.isUndefined,

	'object'  : _.isObject,
	'json'    : function (x) {
		if (_.isUndefined(x)) return false;
		try { JSON.stringify(x); }
		catch(err) { return false; }
		return true;
	},

	'text'		: _.isString,
	'string'	: _.isString,
	'alpha'		: validator.isAlpha,
	'alphadashed': function (x) {return (/^[a-zA-Z-_]*$/).test(x); },
	'numeric'	: validator.isNumeric,
	'alphanumeric': validator.isAlphanumeric,
	'alphanumericdashed': function (x) {return (/^[a-zA-Z0-9-_]*$/).test(x); },
	'email'		: validator.isEmail,
	'url'			: validator.isURL,
	'urlish'	: /^\s([^\/]+\.)+.+\s*$/g,
	'ip'			: validator.isIP,
	'ipv4'		: validator.isIPv4,
	'ipv6'		: validator.isIPv6,
	'creditcard': validator.isCreditCard,
	'uuid'		: validator.isUUID,
	'uuidv3'	: function (x){ return validator.isUUID(x, 3);},
	'uuidv4'	: function (x){ return validator.isUUID(x, 4);},

	'int'			: validator.isInt,
	'integer'	: validator.isInt,
	'number'	: _.isNumber,
	'finite'	: _.isFinite,

	'decimal'	: validator.isFloat,
	'float'		: validator.isFloat,

	'falsey'	: function (x) { return !x; },
	'truthy'	: function (x) { return !!x; },
	'null'		: _.isNull,
	'notNull'	: function (x) { return !validator.isNull(x); },

	'boolean'	: _.isBoolean,

	'array'		: _.isArray,

	'binary'	: function (x) { return Buffer.isBuffer(x) || _.isString(x); },

	'date'		: validator.isDate,
	'datetime': validator.isDate,

	'hexadecimal': validator.hexadecimal,
	'hexColor': validator.isHexColor,

	'lowercase': validator.lowercase,
	'uppercase': validator.uppercase,

	// Miscellaneous rules
	'after'		: validator.isAfter,
	'before'	: validator.isBefore,

	'equals'	: validator.equals,
	'contains': validator.contains,
	'notContains': function (x, str) { return !validator.contains(x, str); },
	'len'			: function (x, min, max) { return validator.len(x, min, max); },
	'in'			: validator.isIn,
	'notIn'		: function (x, arrayOrString) { return !validator.isIn(x, arrayOrString); },
	'max'			: function (x, val) {
		var number = parseFloat(x);
		return isNaN(number) || number <= val;
	},
	'min'			: function (x, val) {
		var number = parseFloat(x);
		return isNaN(number) || number >= val;
	},
	'minLength'	: function (x, min) { return validator.isLength(x, min); },
	'maxLength'	: function (x, max) { return validator.isLength(x, 0, max); },

	'regex' : function (x, regex) { return validator.matches(x, regex); },
	'notRegex' : function (x, regex) { return !validator.matches(x, regex); }

};
