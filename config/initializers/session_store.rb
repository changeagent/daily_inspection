# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_daily_inspection_session',
  :secret      => '47c8bce0961462b7ae7f2b5b08ef0d554705e2674630e639030b8e26cbd484cb6b13c74b592128974ead51da2fef1eb30798b3c3f8190a8957ee21fb23f4054a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
