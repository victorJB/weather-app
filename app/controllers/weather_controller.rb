require 'rest-client'

class WeatherController < ApplicationController
    before_action :validate_city_name, only: [:index]

    def index
        response = RestClient.get("https://search.reservamos.mx/api/v2/places?q=#{params[:city]}")
        render json: response.body
    end

    def validate_city_name
        unless params[:city].present?
          render json: { error: 'Missing city name' }, status: :bad_request
        end
    end
end
