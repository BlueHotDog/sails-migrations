#https://gist.github.com/skovalyov/4605986
fs   = require('fs')
path = require('path')
 
rmdirpSync = (dir) ->
  return unless fs.existsSync(dir)
  list = fs.readdirSync(dir)
  for item in list
    filename = path.join(dir, item)
    stat = fs.statSync(filename)
    if filename in [".", ".."]
      # Skip
    else if stat.isDirectory()
      # Remove directory recursively
      rmdirpSync(filename)
    else
      # Remove file
      fs.unlinkSync(filename)
  fs.rmdirSync(dir)
 
module.exports = rmdirpSync
