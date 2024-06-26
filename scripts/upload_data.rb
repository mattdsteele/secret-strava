require 'dotenv/load'
require_relative '../src/user_repo.rb'
require 'date'

r = SecretStrava::FirestoreUserRepo.new
now = DateTime.now.new_offset(0).iso8601.sub! '+00:00', 'Z'
athlete = {
  athleteId: 1234, accessToken: 'bbb', refreshToken: 'lqwerty', expiresAt: now
}

a = r.create athlete
puts a.inspect

a = r.get(1234)
if a.errors.any?
  puts 'got to errors'
  m = a.errors.details[:data].first
  puts m.inspect
else
  d = a.data.user_by_id.expires_at
  puts DateTime.iso8601(d)
end
