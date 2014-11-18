#!/usr/bin/env node

const _ = require('lodash');
const fs = require("fs");
const path = require('path');
const util = require('util');
const exec = require('child_process').execFile;
const PROJECTS_ROOT = "test/fixtures/sample_apps";
const shell = require('shelljs');

function getDirectories(folder){
  return fs.readdirSync(folder).filter(function(file){
      return fs.statSync(path.join(folder,file)).isDirectory();
    }
  )
}

function puts(error, stdout, stderr) {
  util.print(stdout);
  util.error(stderr);
  if (error !== null) {
    console.log('exec error: ' + error);
  }
}

var directories = getDirectories(path.resolve(PROJECTS_ROOT));

_.forEach(directories, function(version) {
  shell.exec('SAILS_VERSION='+version+' mocha test/specs', function(code, output) {
    if (code!==0) {
      throw "Error running test for version " + version + " " + output;
    }
  });
});
