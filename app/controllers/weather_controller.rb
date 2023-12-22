require 'rest-client'
require 'json'

class WeatherController < ApplicationController
    before_action :validate_city_name, only: [:index]

    def index
        response = RestClient.get("https://search.reservamos.mx/api/v2/places?q=#{params[:city]}")
        cities = JSON.parse(response.body)
        cities_array = []
        threads = []

        cities.each do |x|
            threads << Thread.new do
                city = {
                    name: x["city_name"],
                    lat: x["lat"], 
                    long: x["long"]
                }
                
                if(!city[:lat].nil? && !city[:long].nil? && !city[:name].nil?)
                    temp_array = []
                    response_weather_api = RestClient.get("https://api.openweathermap.org/data/2.5/onecall?lat=#{city[:lat]}&lon=#{city[:long]}&appid=a5a47c18197737e8eeca634cd6acb581")
                    
                    weather_response_api = JSON.parse(response_weather_api.body)
                    daily_weather = weather_response_api["daily"]
                    
                    daily_weather.each do |item|
                        temp_item = {
                            date: Time.at(item["dt"]).strftime("%d/%m/%Y"),
                            temp_min: item["temp"]["min"],
                            temp_max: item["temp"]["max"]
                        }
                        temp_array.push(temp_item)
                    end
                    
                    city_item = {
                        city: city[:name],
                        temperatures: temp_array
                    }
                    
                    cities_array.push(city_item)
                end
            end
        end
        
        threads.each(&:join) 
        render json: cities_array
    end

    def validate_city_name
        unless params[:city].present?
          render json: { error: 'Missing city name' }, status: :bad_request
        end
    end
end
