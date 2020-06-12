module SecretStrava
  class RideClassifier
    def initialize
      @identifiers = [
        CommuteIdentifier.new,
        LongRideIdentifier.new,
        ShortRideIdentifier.new
      ]
    end
    def classify(activity)
      @identifiers.each do |i|
        res = i.classify(activity)
        return res if res != nil
      end
      'followers_only'
    end
  end

  class CommuteIdentifier
    def classify(activity)
      'private' if activity.commute
    end
  end
  class LongRideIdentifier
    def classify(activity)
      'everyone' if activity.distance_in_miles > 30
    end
  end
  class ShortRideIdentifier
    def classify(activity)
      'private' if activity.distance_in_miles < 5
    end
  end
end
