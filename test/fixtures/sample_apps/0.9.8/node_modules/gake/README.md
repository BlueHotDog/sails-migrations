[![NPM version](https://badge.fury.io/js/gake.png)](http://badge.fury.io/js/gake)
# Gake

  Gake is a simple grunt module which allows you to keep your grunt tasks/config separated into different files, much like
  rake.

## Installation

  ```
  $ npm install gake --save
  ```

## Motivation

  This library started out when I needed to create a generator to generate rake like tasks into the [SailsJS](http://sailsjs.org/) project.
  It seems that, for some reason having a 400loc grunt file is a common practice in the NodeJS community.
  Which makes maintaining tasks very needlessly hard and messy.


## Usage

  add this into your grunt config:

  ```
  gake: {
        configDir: './grunt/config',
        tasksDir: './grunt/tasks'
      }
  ```

  and register this npm task **after** you did ```grunt.initConfig```

  ```
  grunt.loadNpmTasks('gake');
  ```

  Now you can use two helper grunt tasks to generate your tasks/configs
  ```
  grunt gake:task --name="my:custom:task"
  ```
  this will create the my/custom/task.js file under the *tasksDir* folder,
  and a my/custom/task.js under the *configDir* folder, where you can put your tasks config files.

  you can also run
  ```
  grunt gake:config --name="my.custom.config"
  ```
  which will generate only the config file.

## Convention

  * **Configuration loading**

    This will load all the config from the *configDir* into the grunt.config object, when the path is the namespace,
    for example, the following path:
    ```
    ./grunt/config/my/task/config.js
    ```
    will create the following config:
    ```
    grunt.config.my.task.config
    ```

  * **Tasks loading**

    This loads all the tasks from the *tasksDir* by requiring all files in the *tasksDir* recursively.

## Examples

  You can take a look at the test folder to see example directory structure and usage.

## TODO

  * Add real tests
  * Add option to generate config/tasks using coffee-script
