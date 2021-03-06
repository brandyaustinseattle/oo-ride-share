require_relative 'spec_helper'

describe "Trip class" do

  describe "initialize" do
    before do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = start_time + 25 * 60 # 25 minutes
      @trip_data = {
        id: 8,
        driver: RideShare::Driver.new(id: 3, name: "Lovelace", vin: "12345678912345678"),
        passenger: RideShare::Passenger.new(id: 1, name: "Ada", phone: "412-432-7640"),
        start_time: start_time,
        end_time: end_time,
        cost: 23.45,
        rating: 3
      }
      @trip = RideShare::Trip.new(@trip_data)
    end

    it "is an instance of Trip" do
      @trip.must_be_kind_of RideShare::Trip
    end

    it "stores an instance of passenger" do
      @trip.passenger.must_be_kind_of RideShare::Passenger
    end

    it "stores an instance of driver" do
      @trip.driver.must_be_kind_of RideShare::Driver
    end

    it "raises an error for an invalid rating" do
      [-3, 0, 6].each do |rating|
        @trip_data[:rating] = rating
        proc {
          RideShare::Trip.new(@trip_data)
        }.must_raise ArgumentError
      end
    end

    it "raises an error when the end time is before the start time" do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = start_time - 25 * 60 # 25 minutes before start
      @trip_data[:start_time] = start_time
      @trip_data[:end_time] = end_time
      proc {
        RideShare::Trip.new(@trip_data)
      }.must_raise ArgumentError
     end
  end

  describe "get_duration method" do
    before do
      @trip_data = {
        id: 8,
        driver: RideShare::Driver.new(id: 3, name: "Lovelace", vin: "12345678912345678"),
        passenger: RideShare::Passenger.new(id: 1, name: "Ada", phone: "412-432-7640"),
      }
      @trip = RideShare::Trip.new(@trip_data)
    end

    it "returns nil if start_time/end_time unavailable" do

      @trip.get_duration.must_equal nil
    end

    it "calculates the duration of the trip in seconds when short time" do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = start_time + 25 * 60 # 25 minutes
      @trip_data[:start_time] = start_time
      @trip_data[:end_time] = end_time
      @trip = RideShare::Trip.new(@trip_data)

      @trip.get_duration.must_equal 1500
    end

    it "calculates the duration of the trip in seconds when long time" do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = start_time + 600 * 60 # 10 hours
      @trip_data[:start_time] = start_time
      @trip_data[:end_time] = end_time
      @trip = RideShare::Trip.new(@trip_data)

      @trip.get_duration.must_equal 36000
    end
  end

  describe "self.total_time(trip_list) method" do
    before do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = start_time + 25 * 60 # 25 minutes
      @trip_data = {
        id: 8,
        driver: RideShare::Driver.new(id: 3, name: "Lovelace", vin: "12345678912345678"),
        passenger: RideShare::Passenger.new(id: 1, name: "Ada", phone: "412-432-7640"),
        start_time: start_time,
        end_time: end_time,
        cost: 23.45,
        rating: 3
      }
      @trip = RideShare::Trip.new(@trip_data)
    end

    it "returns zero when there are no trips" do
      trip_list = []
      RideShare::Trip.total_time(trip_list).must_equal 0
    end

    it "calculates total time when one trip" do
      trip_list = []
      trip_list << @trip
      RideShare::Trip.total_time(trip_list).must_equal 1500
    end

    it "calculates total time when many trips" do
      trip_list = []
      10.times { trip_list << @trip }
      RideShare::Trip.total_time(trip_list).must_equal 15000.0
    end
  end

  describe "trip_in_progress? method" do
    before do
      @trip_data = {
        id: 8,
        driver: RideShare::Driver.new(id: 3, name: "Lovelace", vin: "12345678912345678"),
        passenger: RideShare::Passenger.new(id: 1, name: "Ada", phone: "412-432-7640"),
      }
      @trip = RideShare::Trip.new(@trip_data)
    end

    it "returns false if no trips taken" do
      @trip.trip_in_progress?.must_equal false
    end

    it "returns true if trip is in progress" do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      @trip_data[:start_time] = start_time
      @trip = RideShare::Trip.new(@trip_data)

      @trip.trip_in_progress?.must_equal true
    end

    it "returns false if trip has an end time" do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = start_time + 25 * 60 # 25 minutes
      @trip_data[:start_time] = start_time
      @trip_data[:end_time] = end_time
      @trip = RideShare::Trip.new(@trip_data)

      @trip.trip_in_progress?.must_equal false
    end
  end

  describe "time_since_trip method" do
    before do
      @trip_data = {
        id: 8,
        driver: RideShare::Driver.new(id: 3, name: "Lovelace", vin: "12345678912345678"),
        passenger: RideShare::Passenger.new(id: 1, name: "Ada", phone: "412-432-7640"),
      }
      @trip = RideShare::Trip.new(@trip_data)
    end

    it "returns nil if end_time is nil" do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      @trip_data[:start_time] = start_time

      @trip.time_since_trip.must_equal nil
    end

    it "returns a length of time if end_time present" do
      start_time = Time.parse('2018-2-27T12:14:00+00:00')
      end_time = start_time + 25 * 60 # 25 minutes
      @trip_data[:start_time] = start_time
      @trip_data[:end_time] = end_time
      @trip = RideShare::Trip.new(@trip_data)

      @trip.time_since_trip.must_be_instance_of Float
    end
  end

end
