exports.up = function(adapter, done) {
  adapter.addAttribute('two_migrations', 'email', {type: 'STRING'}, function(err, schema){
    done(err);
  });
};

exports.down = function(adapter, done) { 
  done();
};


