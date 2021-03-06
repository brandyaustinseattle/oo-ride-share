require_relative 'spec_helper'

describe "Passenger class" do

  describe "Passenger instantiation" do
    before do
      @passenger = RideShare::Passenger.new({id: 1, name: "Smithy", phone: "353-533-5334"})
    end

    it "is an instance of Passenger" do
      @passenger.must_be_kind_of RideShare::Passenger
    end

    it "throws an argument error with a bad ID value" do
      proc{ RideShare::Passenger.new(id: 0, name: "Smithy")}.must_raise ArgumentError
    end

    it "sets trips to an empty array if not provided" do
      @passenger.trips.must_be_kind_of Array
      @passenger.trips.length.must_equal 0
    end

    it "is set up for specific attributes and data types" do
      [:id, :name, :phone_number, :trips].each do |prop|
        @passenger.must_respond_to prop
      end

      @passenger.id.must_be_kind_of Integer
      @passenger.name.must_be_kind_of String
      @passenger.phone_number.must_be_kind_of String
      @passenger.trips.must_be_kind_of Array
    end
  end

  describe "get_total_spent method" do
    before do
      @passenger = RideShare::Passenger.new(id: 9, name: "Merl Glover III", phone: "1-602-620-2330 x3723", trips: [])
    end

    it "total_spent is zero if no trips taken" do
      @passenger.get_total_spent.must_equal 0
    end

    it "total_spent is calculated with one trip" do
      trip = RideShare::Trip.new({id: 1, driver: @driver, passenger: pass, cost: 15.00, rating: 5})
      @passenger.add_trip(trip)

      @passenger.get_total_spent.must_equal 15.00
    end

    it "get_total_spent is calculated with many trips" do
      trip = RideShare::Trip.new({id: 1, driver: @driver, passenger: pass, cost: 15.00, rating: 5})
      10.times { @passenger.add_trip(trip) }

      @passenger.get_total_spent.must_equal 150.00
    end

    it "get_total_spent is 0 if passenger only has a trip in progress" do
      @passenger.trips.empty?.must_equal true

      start_time = Time.parse('2015-05-20T12:14:00+00:00')

      trip = RideShare::Trip.new({id: 1, driver: @driver, passenger: pass, start_time: start_time})

      @passenger.add_trip(trip)

      @passenger.get_total_spent.must_equal 0
    end
  end

  describe "trips property" do
    before do
      @passenger = RideShare::Passenger.new(id: 9, name: "Merl Glover III", phone: "1-602-620-2330 x3723", trips: [])
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = start_time + 25 * 60 # 25 minutes
      trip = RideShare::Trip.new({id: 8, driver: nil, passenger: @passenger, start_time: start_time, end_time: end_time, rating: 5})

      @passenger.add_trip(trip)
    end

    it "each item in array is a Trip instance" do
      @passenger.trips.each do |trip|
        trip.must_be_kind_of RideShare::Trip
      end
    end

    it "all Trips must have the same Passenger id" do
      @passenger.trips.each do |trip|
        trip.passenger.id.must_equal 9
      end
    end
  end

  describe "get_drivers method" do
    before do
      @passenger = RideShare::Passenger.new(id: 9, name: "Merl Glover III", phone: "1-602-620-2330 x3723")
      driver = RideShare::Driver.new(id: 3, name: "Lovelace", vin: "12345678912345678")
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = start_time + 25 * 60 # 25 minutes
      trip = RideShare::Trip.new({id: 8, driver: driver, passenger:
      @passenger, start_time: start_time, end_time: end_time, rating: 5})

      @passenger.add_trip(trip)
    end

    it "returns an array" do
      drivers = @passenger.get_drivers
      drivers.must_be_kind_of Array
      drivers.length.must_equal 1
    end

    it "all items in array are Driver instances" do
      @passenger.get_drivers.each do |driver|
        driver.must_be_kind_of RideShare::Driver
      end
    end
  end

  describe "get_total_time method" do
    before do
      @passenger = RideShare::Passenger.new({id: 1, name: "Smithy", phone: "353-533-5334"})
    end

    it "trip time is zero if no trips taken" do
      @passenger.get_total_time.must_equal 0
    end

    it "trip time returns zero if trip exists but duration nil" do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      trip = RideShare::Trip.new({id: 1, driver: @driver, passenger: pass, start_time: start_time, cost: 15.00, rating: 5})
      @passenger.add_trip(trip)

      @passenger.get_total_time.must_equal 0
    end

    it "trip time is calculated with one trip" do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = start_time + 25 * 60 # 25 minutes
      trip = RideShare::Trip.new({id: 1, driver: @driver, passenger: pass, start_time: start_time, end_time: end_time, cost: 15.00, rating: 5})
      @passenger.add_trip(trip)

      @passenger.get_total_time.must_equal 1500
    end

    it "trip time is calculated with many trips" do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = start_time + 25 * 60 # 25 minutes
      trip = RideShare::Trip.new({id: 1, driver: @driver, passenger: pass, start_time: start_time, end_time: end_time, cost: 15.00, rating: 5})
      10.times { @passenger.add_trip(trip) }

      @passenger.get_total_time.must_equal 15000.0
    end
  end

  describe "accept_trip method" do
    before do
      @passenger = RideShare::Passenger.new({id: 1, name: "Smithy", phone: "353-533-5334"})
    end

    it "trip is added to driver's array when called" do
      @passenger.trips.empty?.must_equal true

      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = start_time + 25 * 60 # 25 minutes
      trip = RideShare::Trip.new({id: 1, driver: @driver, passenger: pass, start_time: start_time, end_time: end_time, cost: 15.00, rating: 5})
      10.times { @passenger.add_trip(trip) }

      @passenger.accept_trip(trip)
      @passenger.trips.empty?.must_equal false
    end
  end

end
