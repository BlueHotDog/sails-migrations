var definitionName = 'email'

exports.up = function(adapter, done) {
  adapter.addAttribute('many_migrations', definitionName, {type: 'STRING'}, function(err, schema){
    done(err);
  });
};

exports.down = function(adapter, done) { 
  adapter.removeAttribute('many_migrations', 'email', function(err, schema){
    done(err);
  });
};
