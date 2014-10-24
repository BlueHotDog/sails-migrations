_ = require('lodash')
path = require('path')
fs = require('fs')
dot = require('dot')
mkdirp = require('mkdirp')

TASK_NAME_SEPARATOR = ":"
CONFIG_NAME_SEPARATOR = "."

class Generator
  generateTemplate= (grunt, separator, baseOutputPath, outputPath, templatePath, context)->
    allPaths = outputPath.split(separator)
    taskFileName = allPaths.pop()
    if path.extname(taskFileName) != "js"
      taskFileName = "#{taskFileName}.js"

    pathWithoutFile = path.join(baseOutputPath, allPaths.join(path.sep))
    mkdirp.sync(pathWithoutFile)

    temp = dot.template(fs.readFileSync(templatePath))
    fullTaskNameToCreate = path.join(pathWithoutFile, taskFileName)
    if path.existsSync(fullTaskNameToCreate)
      grunt.fatal("there is already file named #{fullTaskNameToCreate}, please choose another or delete")

    err = fs.writeFileSync(fullTaskNameToCreate, temp(context))
    grunt.warn(err) if err

  @register: (grunt) ->
    dot.templateSettings.strip = false
    grunt.registerTask('gake', 'generate a new grunt task', (generatorType)->
      validGenerators = ['task','config']
      if generatorType && _.contains(validGenerators, generatorType)
        Generator[generatorType].call(@, grunt)
      else
        grunt.fail.fatal("please specify either #{validGenerators}")
    )

  @task: (grunt)->
    grunt.log.writeln("Generating task with name")
    taskName = grunt.option('name')
    grunt.warn("""
                   please specify task name using the --name='<task name>' option.
                   If your task name includes the '#{TASK_NAME_SEPARATOR}' character, for example 'my:custom:task'
                   it'll create the following file #{path.join(grunt.config('gake.tasksDir'),'my','custom','task.js')}
               """) if _.isEmpty(taskName)

    generateTemplate(grunt,
      TASK_NAME_SEPARATOR,
      grunt.config('gake.tasksDir'),
      taskName,
      path.join(__dirname, 'templates/task.js'),
      { grunt:grunt, name: taskName }
    )
    generateTemplate(grunt,
      TASK_NAME_SEPARATOR,
      grunt.config('gake.configDir'),
      taskName,
      path.join(__dirname, 'templates/config.js'),
      { grunt:grunt, name: taskName }
    )
    true

  @config: (grunt)->
    grunt.log.writeln("Generating config with name")
    configName = grunt.option('name')
    grunt.warn("""
                   please specify config name using the --name='<task name>' option.
                   If your config name includes the '#{CONFIG_NAME_SEPARATOR}' character, for example 'my.custom.config'
                   it'll create the following file #{path.join(grunt.config('gake.configDir'),'my','custom','config.js')}
               """) if _.isEmpty(configName)

    template = path.join(__dirname, 'templates/config.js')
    generateTemplate(grunt, CONFIG_NAME_SEPARATOR, grunt.config('gake.configDir'), configName, template, {grunt:grunt, name: configName})
    true


module.exports = Generator.register.bind(Generator)