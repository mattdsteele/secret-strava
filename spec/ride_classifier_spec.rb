require_relative './spec_helper'
require_relative '../src/ride_classifier'
require 'strava-ruby-client'

def act(f)
  Marshal.load(IO.read "./spec/fixtures/activities/#{f}")
end

describe 'ride classifier' do
  it 'does not identify as big ride as private' do
    c = SecretStrava::RideClassifier.new
    r = c.classify(act('bigride'))
    expect(r).to eq 'followers-only'
  end
  it 'identifies commutes as private' do
    c = SecretStrava::RideClassifier.new
    r = c.classify(act('commute'))
    expect(r).to eq 'private'
  end
  it 'identifies short rides as private' do
    c = SecretStrava::RideClassifier.new
    r = c.classify(act('shortride'))
    expect(r).to eq 'private'
  end
  it 'identifies indoor rides as private' do
    c = SecretStrava::RideClassifier.new
    r = c.classify(act('indoor-short'))
    expect(r).to eq 'private'
  end
end
