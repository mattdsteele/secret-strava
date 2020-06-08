require 'dotenv/load'
require_relative '../src/user_repo.rb'
require 'date'

r = SecretStrava::UserRepo.new
now = DateTime.now.new_offset(0).iso8601.sub! '+00:00', 'Z'
athlete = {
  athleteId: 1234, accessToken: 'bbb', refreshToken: 'lqwerty', expiresAt: now
}

=begin
a = r.create athlete
puts a.inspect
=end

a = r.get(1234)
d = a.data.user_by_id.expires_at
puts a.inspect
puts DateTime.iso8601(d)
