LocalStrategy = require('passport-local').Strategy
User    = require '../models/user'
apiUrl  = require('./serverConfig')['url']
bcrypt  = require 'bcrypt-nodejs'

module.exports = (passport) ->
  
  # =========================================================================
  # passport session setup ==================================================
  # =========================================================================
  # required for persistent login sessions
  # passport needs ability to serialize and unserialize users out of session
  
  # used to serialize the user for the session
  passport.serializeUser (user, done) ->
    done null, user.id

  # used to deserialize the user
  passport.deserializeUser (id, done) ->
    User.findById id, (err, user) ->
      done err, user

  # =========================================================================
  # LOCAL SIGNUP ============================================================
  # =========================================================================
  # Using named strategies since we have one for login and one for signup
  # by default, if there was no name, it would just be called 'local'
  passport.use "local-signup", new LocalStrategy(
    
    # by default, local strategy uses username/password, override with email
    usernameField: "email"
    passwordField: "password"
    passReqToCallback: true # pass back the entire req to the callback
  , (req, email, password, done) ->
    
    # find a user whose email is the same as the forms email
    # we are checking to see if the user trying to login already exists
    User.findOne
      "email": email
    , (err, user) ->
      
      # if there are any errors, return the error
      if err
        return done err
      # check to see if theres already a user with that email
      if user
        console.log "EMAIL IS TAKEN"
        return done null, false
      else
        # if there is no user with that email, create new user
        newUser = new User()
        newUser.email = email
        # generate password salt
        bcrypt.genSalt 10, (err, salt) ->
          if err
            console.error 'bcrypt.genSalt error: ', err
            return done err
          # hash password with salt
          bcrypt.hash password, salt, null, (err, hash) ->
            if err
              console.error 'bcrypt.hash error: ', err
              return done err
            newUser.password = hash
            newUser.salt = salt
            newUser.save (err) ->
              if err
                console.error 'error - could not save user ', err
                return done err
              return done null, newUser
  )