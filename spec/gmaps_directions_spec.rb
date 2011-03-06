require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "GmapsDirections" do

  it 'should provide a way to calculate the directions between points speficied by address' do
    start_address = "Somestr. 23, 99999 Any City"
    end_address   = "Just Avenue 42, 11111 Sin City"

    directions_api_url = URI.parse("http://maps.googleapis.com/maps/api/directions/json?origin=#{URI.encode(start_address)}&destination=#{URI.encode(end_address)}&mode=driving&units=metric&language=en&sensor=false&alternatives=false")
    Yajl::HttpStream.should_receive(:get).with(directions_api_url)
    GmapsDirections::Route.should_receive(:new)

    GmapsDirections::API.find_directions :from => start_address, :to => end_address
  end

  describe "should have a Config object" do

    before(:each) do
      GmapsDirections::Config.reset_to_defaults!
    end
    
    it 'should provide a way to configure some defaults when talking with the directions API' do
      GmapsDirections::Config.mode = :walking
      GmapsDirections::Config.mode.should == :walking

      GmapsDirections::Config.units = :imperial
      GmapsDirections::Config.units.should == :imperial

      GmapsDirections::Config.language = :de
      GmapsDirections::Config.language.should == :de

      GmapsDirections::Config.sensor = true
      GmapsDirections::Config.sensor.should be(true)

      GmapsDirections::Config.alternatives = true
      GmapsDirections::Config.alternatives.should be(true)
    end

    it 'should provide a meaningful default configuration out of the box' do
      GmapsDirections::Config.mode.should           == :driving
      GmapsDirections::Config.units.should          == :metric
      GmapsDirections::Config.language.should       == :en
      GmapsDirections::Config.sensor.should         be(false)
      GmapsDirections::Config.alternatives.should   be(false)
    end

    it 'should transform the config to URL options' do
      GmapsDirections::Config.to_url_options.should == "mode=driving&units=metric&language=en&sensor=false&alternatives=false"
    end

  end

  describe "should wrap Google's JSON response in a nice object and" do

    before(:each) do
      @route = GmapsDirections::Route.new(
        {
          "status" => "OK",
          "routes" => [ {
            "summary" => "Luxemburger Str./B265",
            "legs" => [ {
              "steps" => [ { 
                "travel_mode" => "DRIVING",
                "start_location" => { "lat" => 50.9280500, "lng" => 6.9397100 },
                "end_location" => { "lat" => 50.9274800, "lng" => 6.9397800 },
                "polyline" => { },
                "duration" => { "value" => 11, "text" => "1 min" },
                "html_instructions" => "",
                "distance" => { "value" => 63, "text" => "63 m" }
              } ],
              "duration" => {
                "value" => 476,
                "text" => "8 mins"
              },
              "distance" => {
                "value" => 3166,
                "text" => "3.2 km"
              },
              "start_location" => { "lat" => 50.9280500, "lng" => 6.9397100 },
              "end_location" => { "lat" => 50.9093600, "lng" => 6.9246200 },
              "start_address" => "Somestr. 23, 99999 Any City, USA",
              "end_address" => "Just Avenue 42, 11111 Sin City, USA",
              "via_waypoint" => [ ]
            } ],
            "copyrights" => "Map data ©2011 Tele Atlas",
            "overview_polyline" => { },
            "warnings" => [ ],
            "waypoint_order" => [ ],
            "bounds" => { }
          } ]
        }
      )
    end
    
    it 'should provide a getter to the duration' do
      @route.duration.should == 476
    end

    it 'should provide a getter to the localized and formatted duration' do
      @route.formatted_duration.should == "8 mins"
    end

    it 'should provide a getter to the distance' do
      @route.distance.should == 3166
    end

    it 'should provide a getter to the localized and formatted distance' do
      @route.formatted_distance.should == "3.2 km"
    end

    it 'should provide a getter to the submitted start address' do
      @route.start_address.should == "Somestr. 23, 99999 Any City, USA"
    end

    it 'should provide a getter to the submitted end address' do
      @route.end_address.should == "Just Avenue 42, 11111 Sin City, USA"
    end

    it 'should provide a getter to the geocoordinates of the start address' do
      @route.start_location.should == { "lat" => 50.9280500, "lng" => 6.9397100 }
    end

    it 'should provide a getter to the geocoordinates of the end address' do
      @route.end_location.should == { "lat" => 50.9093600, "lng" => 6.9246200 }
    end

    it 'should provide a getter to status of the Google response' do
      @route.status.should == "OK"
    end

  end

  it 'should perform a real request see if everything is parsed correctly' do
    route = GmapsDirections::API.find_directions :from => "1 Infinite Loop, Cupertino",
                                                 :to => "1200 Park Avenue, Emmerville"

    route.duration.should           == 3462
    route.formatted_duration.should == "58 mins"
    route.distance.should           == 84826
    route.formatted_distance.should == "84.8 km"
    route.start_address.should      == "1 Infinite Loop, Cupertino, CA 95014, USA"
    route.end_address.should        == "1200 Park Ave, Emeryville, CA 94608, USA"
    route.start_location.should     == { "lat" => 37.3316900, "lng" => -122.0312600 }
    route.end_location.should       == { "lat" => 37.8317100, "lng" => -122.2833000 }
    route.status.should             == "OK"
  end
end
