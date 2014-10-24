/**
 * Run a function recursively, using a seed item
 *
 * @param {Function} function to run that processes a stack item
 * @param {Object} item to seed the stack with
 * @param {Function} callback
 */

module.exports = function(fn, item, cb) {

  // Create a stack to hold recursive items
  var stack = [];

  // Hold the top level item
  var topLevelItem = null;

  // Seed the stack with an item, handling an object or an array
  if (Array.isArray(item)) {
    stack = item;
  } else {
    stack.push(item);
  }

  // Kick off Parsing
  processStack();

  /**
   * Recurisvely Parse a single stack item
   *
   * Manages processing stack items and running the specified function.
   */

  function processStack() {

    if(stack.length === 0) return cb(null, topLevelItem);

    // Pop an item off the stack
    var item = stack.pop();

    fn.call(null, item, stack, function(err, result) {
      if(err) return cb(err);
      if(!topLevelItem && result) topLevelItem = result;
      processStack();
    });

  }
};
