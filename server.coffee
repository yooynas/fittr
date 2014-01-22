# requiring dependencies

express = require 'express'
mongoose = require 'mongoose'
passport = require 'passport'

###### TO-DO - CHANGE ALL INSTANCES OF COFFEE WITH JS ##########
cors = require './app/coffee/config/middleWare'
mongoConfig = require './app/coffee/config/dbconfig'
port  = require('./app/coffee/config/serverConfig')['port']

# connect to DB
mongoose.connect mongoConfig.url

# Populate passport object with strategies
require('./app/coffee/config/passport')(passport)

app = express()
app.set 'port', port

# Middleware
app.use express.logger('dev')
app.use cors.headers
app.use express.favicon()
app.use express.cookieParser()
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.session secret: 'superfit'
app.use passport.initialize()
app.use passport.session()
app.use app.router
app.use express.static __dirname + '/public'

# routes for api and DB endpoints
require('./app/coffee/config/routes')(app, passport)

module.exports = app