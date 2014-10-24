path = require('path')
Promise = require('bluebird')
BASE_PATH = path.resolve('test/fixtures/sample_apps')
shell = require('shelljs')
_ = require('lodash')

version = process.env.SAILS_VERSION

describe "cli #{version}", ->
  before (done)->
    @timeout(50000)
    @sampleAppPath = path.resolve(BASE_PATH, version)
    @migrationsPath = path.resolve(@sampleAppPath + "/db/migrations")

    shell.exec("npm link", silent: true)
    shell.cd(@sampleAppPath)
    shell.exec("npm link sails-migrations", silent: true)
#    shell.exec("npm install")
    configLoader = require("#{@sampleAppPath}/node_modules/sails-migrations/lib/sails-migrations/helpers/config_loader")
    configLoader.load().then((@config)=>
      ###
        this weird thing is here since we want to keep no connections open to the db, so we'll be able to drop and recreate
        it as needed
      ###
      @getAllMigrations = (cb)->
        knex = require('knex')(@config)
        knex.select('*').from(@config.migrations.tableName).exec((err, res)->
          knex.destroy(->
            cb(err, res)
          )
        )
      done()
    )



  beforeEach ->
    shell.rm('-rf', @migrationsPath)
    shell.exec('sails-migrations db:drop', silent: true)
    shell.exec('sails-migrations db:create', silent: true)


  describe "generate", ->
    context "when no :name param is given", ->
      it 'it should complain that a name must be given', ->
        result = shell.exec("sails-migrations generate", silent: true)
        expect(result.code).to.eql 1 #we need to fail
        expect(result.output).to.have.string 'error: missing required argument `name\''

    context "when a :name param is given", ->
      beforeEach ->
        NAME = "my awesome name"
        @result = shell.exec("sails-migrations generate '#{NAME}'", silent: true)

      it 'should exit successfully', ->
        expect(@result.code).to.not.eql 1

      it 'should create the migration', ->
        files = shell.ls(@migrationsPath)
        expect(files.length).to.equal 1
        migrationWithoutTheTimestamp = _.rest(files[0].split('_')).join('_')
        expect(migrationWithoutTheTimestamp).to.eql 'my_awesome_name.js'


  describe "migrate", ->
    context "when the migrations folder does not exists", ->
      it "should report an error", ->
        result = shell.exec("sails-migrations migrate", silent: true)
        expect(result.output).to.have.string "/db/migrations does not exists"
        expect(result.code).to.eq 1

    context "when there are no migration files", ->
      beforeEach ->
        shell.mkdir('-p', @migrationsPath)

      it "should do nothing", ->
        result = shell.exec("sails-migrations migrate", silent: true)
        expect(result.output).to.have.string "Already up to date"
        expect(result.code).to.eq 0

    context "when there are multiple migration files", ->
      beforeEach ->
        shell.exec("sails-migrations generate 'migration 1'", silent: true)
        shell.exec("sails-migrations generate 'migration 2'", silent: true)

      it "should run them", (done)->
        migrationFiles = shell.ls(@migrationsPath)
        expect(migrationFiles.length).to.equal 2
        shell.exec('sails-migrations migrate', silent: true)
        @getAllMigrations((err, res)->
          expect(res.length).to.eql 2
          expect(_.pluck(res, 'batch')).to.eql [1, 1]
          expect(_.pluck(res, 'name')).to.eql migrationFiles
          done(err)
        )


  describe "rollback", ->
    it 'should rollback the migrations', (done)->
      shell.exec('sails-migrations db:create', silent: true)
      shell.exec("sails-migrations generate 'migration 1'", silent: true)
      shell.exec('sails-migrations migrate', silent: true)
      shell.exec('sails-migrations rollback', silent: true)
      @getAllMigrations((err, res)->
        expect(res.length).to.eql 0
        done(err)
      )


  ###
  no idea how to test those..
  ###
  #    describe "db:create", ->
  #      it "should create the db", (done)->
  #    describe "db:drop", ->
  #      it "should drop the db", ->

  describe "current_version", ->
    context "when no migrations are run", ->
      it "should return none", ->
        shell.exec("sails-migrations generate 'migration 1'", silent: true)
        result = shell.exec('sails-migrations current_version', silent: true)
        expect(result.output).to.have.string 'none'

    it "should return the correct version", ->
      shell.exec("sails-migrations generate 'migration 1'", silent: true)
      shell.exec('sails-migrations migrate', silent: true)
      result = shell.exec('sails-migrations current_version', silent: true)
      files = shell.ls(@migrationsPath)
      migrationTimestamp = _.first(files[0].split('_'))
      expect(result.output).to.have.string migrationTimestamp
