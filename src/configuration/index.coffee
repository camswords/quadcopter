environment = process.ENV || 'development'
module.exports = require("./#{environment}.json")
