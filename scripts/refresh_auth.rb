require_relative '../src/user_repo'
require 'date'

r = SecretStrava::FirestoreUserRepo.new
user_data = r.get_or_refresh 1_751_710

expiry_data = user_data.expires_at
expiry = DateTime.iso8601 expiry_data
earlier = (expiry <=> DateTime.now) == -1
puts 'token still good' unless earlier
