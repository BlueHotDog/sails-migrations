var definitionName = 'email'

exports.up = function(adapter, done) {
  adapter.addAttribute('two_migrations', definitionName, {type: 'STRING'}, function(err, schema){
    done(err);
  });
};

exports.down = function(adapter, done) { 
  adapter.removeAttribute('two_migrations', 'email', function(err, schema){
    done(err);
  });
};
