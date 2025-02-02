module SecretStrava
  class RideClassifier
    def initialize
      @identifiers = [
        CommuteIdentifier.new,
        LongRideIdentifier.new,
        ShortRideIdentifier.new
      ]
      @classifiers = [
        BikeIdentifier.new,
        CustomNameIdentifier.new
      ]
    end
    def classify(activity, check_classify = true)
      return nil if check_classify and !@classifiers.all? {|c| c.classify(activity)}

      @identifiers.each do |i|
        res = i.classify(activity)
        return res if res != nil
      end
      'followers_only'
    end
  end

  class BikeIdentifier
    def classify(activity)
      activity.type == 'Ride'
    end
  end
  class CustomNameIdentifier
    def classify(activity)
      name = activity.name
      (name =~ /(Morning|Evening|Lunch|Afternoon|Night) [\w ]*Ride/).eql? 0
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
