anchor
======

Anchor is a javascript library that lets you define strict types.
<!-- err todo: It also helps you validate and normalize the usage of command line scripts and even individual functions. -->

This makes it really useful for things like:
+ Form validation on the client or server
+ Ensuring compliance with an API
+ Ensuring that the proper arguments were passed into a function or command-line script
+ Validating objects before storing them in a data store
+ Normalizing polymorphic behaviors

Adds support for strongly typed arguments, like http://lea.verou.me/2011/05/strongly-typed-javascript/, but goes a step further by adding support for array and object sub-validation.
It's also the core validation library for the Sails ecosystem. 

(Built on top of the great work with https://github.com/chriso/node-validator)

## Installation

### Client-side
```html
<script type='text/javscript' src="/js/anchor.js"></script>
```

### node.js
```bash
npm install anchor
```

<!--

## Basic Usage
```javascript
var anchor = require('anchor');

var userData = 'some string';

// This will guarantee that userData is a string
// If it's not, an error will be thrown
userData = anchor(userData).to('string');

// If you want to handle the error instead of throwing it, use a callback
anchor('something').to("string", function (err) {
  // Err is an error object with a subset of the original data that didn't pass
  // Specifying a callback will prevent an error from being thrown
});

```

## Objects
```javascript

// Limit data to match these requirements
var requirements = anchor({
  name: 'string',
  avatar: {
    path: 'string'
    name: 'string',
    size: 'int',
    type: 'string'
  }
});

// Unvalidated data from the user
var userData = {
  name: 'Elvis',
  avatar: {
    path: '/tmp/2Gf8ahagjg42.jpg',
    name: '2Gf8ahagjg42.jpg',
    size: 382944
    type: 'image/jpeg'
  }
};

// Verify that the userData at least contains your requirements
// It can have EXTRA keys, but it MUST have the keys you specify
anchor(userData).to(requirements);

```

-->

<!--
## Custom rules

Anchor also supports custom validation rules.
```javascript

// Define a compound validation rule using anchor types
anchor.define('file').as({
  name: 'string',
  type: 'string',
  size: 'int',
  type: 'int'
});

// Define a custom rule using a function
anchor.define('supportedFruit').as(function (fruit) {
  return fruit === 'orange' || fruit === 'apple' || fruit === 'grape';
});


// you can use your new validation rules like any standard anchor data type:
anchor(someUserData).to({
  name: 'string',
  avatar: 'file'
});

anchor(someUserData).to({
  fruit: 'supportedFruit'
});
```

We bundled a handful of useful defaults:
```javascript
anchor(someUserData).to({
  id: 'int',
  name: 'string',
  phone: 'phone',
  creditcard: 'creditcard',
  joinDate: 'date',
  email: 'email',
  twitterHandle: 'twitter'
});
```


The example below demonstrates the complete list of supported default data types:
```javascript
anchor(userData).to({
  id: 'int',
  name: 'string',
  phone: 'phone',
  creditcard: 'creditcard',
  joinDate: 'date',
  email: 'email',
  twitterHandle: 'twitter',
  homepage: 'url',
  
  // This requires any data
  someData: {},
  
  // This will require a list of >=0 hex colors
  favoriteColors: ['htmlcolor'],
  
  // This will require a list of >=0 badge objects, as defined:
  badges: [{
    name: 'string',
    // This will require a list of privilege objects, as defined:
    privileges: [{
      id: 'int'
      permission: 'string'
    }]
  }]
});
```


## Functions

> TODO: Support for functions is incomplete.  If you'd like to contribute, please reach out at @balderdashy!

It also has built-in usage to verify the arguments of a function.
This lets you be confident that the arguments are what you expect.
```javascript
$.get = anchor($.get).usage(
  // You can specify multiple usages
  ['urlish',{}, 'function'],
  ['urlish','function'],
  ['urlish',{}],
  ['urlish']
);

// The following usage will throw an error because agasdg is not urlish
$.get('agasdg', {}, function (){})

// You can use the same callback from above in your definition to handle the error yourself
$.get = anchor($.get).usage(
  ['urlish',{}, 'function'],
  ['urlish','function'],
  ['urlish',{}],
  ['urlish'],
  function (err) {
  // Do something about the error here
});
```

### Multiple usages and Argument normalization

But sometimes you want to support several different argument structures.  
And to do that, you have to, either explicitly or implicitly, name those arguments so your function can know which one was which, irrespective of how the arguments are specified.
Here's how you specify multiple usages:

```javascript



// This will create a copy of the function that only allows usage that explicitly declares an id
var getById = anchor(
  function (args) {
    // the args object is constructed based on the arguments and usage you define below
    $.get(args.endpoint, {
      id: args.id
    }, args.done);
  })
  
  // Here you can define your named arguments as temporal custom data types, 
  // each with their OWN validation rules
  .args({
    endpoint: 'urlish',
    id: 'int'
    done: 'function'
  })
  
  // To pass valiation, the user arguments must match at least one of the usages below
  // and each argument must pass its validation definition above
  .usage(
    ['endpoint', 'id', 'done'],
    
    // Callback is optional
    ['endpoint', 'id']
  );
```


### Call it any way you want
Now the cool part.  You can call your new function any of the following ways:

```javascript
$.getById('/user',3,cb);
$.getById('/user',3);
```



## Default values
You can also specify default values.  If it's not required, if a value listed in defaults is undefined, the default value will be substituted.  A value should not have a default AND be required-- one or the other.

Here's an example for an object's keys:
```javascript
anchor(myObj)
  .to({
    id: 'int'
    name: 'string',
    friends: [{
      id: 'int'
    }]
  })
  .defaults({
    name: 'Anonymous',
    friends: [{
      id: 'int',
      name: 'Anonymous'
    }]
  })
```

And here's an example for a function's arguments:
```javascript
anchor(myFunction)
  .args({
    id: 'int',
    options: {}
  })
  .defaults({
    
  }),
  .usage(
    ['id'],
    ['options']
    ['id', 'options']
  );
```




## Asynchronous Usage / Promises
Anchor can also help you normalize your synchronous and asynchronous functions into a uniform api.  It allows you to support both last-argument-callback (Node standard) and promise usage out of the box.

> TODO



## Express/Connect Usage
```javascript
app.use(require('anchor'));

// ...

function createUser (req,res,next) {
  // Any errors will be handled by Express/Connect
  var params = req.anchor.to({
    id: 'int',
    name: 'string'
  });
  
  
  // Do stuff here
  // This could be anything-- we chose to demonstrate a create method 
  // in this case from our favorite ORM, Waterline (http://github.com/mikermcneil/waterline)
   async.auto([
        
      // Create the user itself
      user: User.create(params).done,
      
      // Grant permission for the user to administer itself
      permission: Permission.create({
        targetModel : 'user',
        targetId    : params.id,
        UserId      : params.id,
      }).done
      
    ], function (err, results) {
    
      // Just basic usage, but this prevents you from dealing with non-existent values and null pointers
      // both when providing a consistent API on the server-side 
      // AND when marshalling server-sent data on the client-side
      // i.e. this sucks: user.friends && user.friends.length && user.friends[0] && user.friends[0].id
      var user = res.anchor(results.user).to({
        id: 'int',
        name: 'string',
        email: 'email',
        friends: [{
          id: 'int',
          name: 'string',
          email: 'string'
        }]
      });
      
      // Respond with JSON
      // Could just pass the user object, 
      // but in this case we're demonstrating a custom mapping 
      // (like you might use to implement a custom, predefined API)
      // You can safely know all the .'s you're using won't result in any errors, since you validated this above
      res.json({
        user_id           : user.id,
        user_full_name    : user.name,
        user_email_address: user.email,
        friends           : user.friends
      });
  });
  
}
```


## Sails Usage

Anchor is bundled with Sails.  You can use anchor in Sails just like you would with the connect/express middleware integration, but you can also take an advantage of the extended functionality as seen below.

Here's an example of how you might right your `create()` action to comply with a predefined API in Sails using built-in Anchor integration:
> Note: In practice, you'd want to pull the function that creates the user and the permission out and put it in your model file, overriding the default User.create() behaviour.

```javascript
// UserController.js

var UserController = {
  create: {
    
    // Marshal the request 
    request   : {
      id    : 'int',
      name  : 'string'
    },
    
    // Marshal the response to use the predetermined API
    response  : {
      user_id             : 'user.id'
      user_full_name      : 'user.name'
      user_email_address  : 'user.email'
      friends             : 'user.friends'
    },
    
    // Define an arbitrarily named attribute that will be used in response
    // and the function that will populate it
    // The function will be called with the entire request object as the first parameter
    // Expects a callback like: function (err, result) {}   [where result === user]
    user      : User.create

  }
};
module.exports = UserController;

```

The model validation also uses anchor:
```javascript
// User.js
var User = {
  adapter: 'mongo',
  
  attributes: {
    id: 'int',
    name: 'string',
    email: 'email',
    friends: [{
      id: 'int',
      name: 'string',
      email: 'string'
    }]
  },
  
  // Create a user, but also create the permission for it to manage itself
  create: function (values,cb) {
    
    async.auto({
      
      // Create the user itself
      user: User.create(values).done,
      
      // Grant permission for the user to administer itself
      permission: Permission.create({
        targetModel : 'user',
        targetId    : values.id,
        UserId      : values.id,
      }).done
      
    ], function (err, results) {
      cb(err, results.user);
    });
  }
};
module.exports = User;

```

-->

## Tests
```
npm test
```


## Who Built This?
Anchor was developed by @mikermcneil and is supported by Balderdash Co (@balderdashy).
Hopefully, it makes your life a little bit easier!


The MIT License (MIT)
--

Copyright © 2012- Mike McNeil

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/18e6e2459aed1edbdee85d77d63b623b "githalytics.com")](http://githalytics.com/balderdashy/anchor)

