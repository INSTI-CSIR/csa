

# app.rb
require 'sinatra'
require 'sinatra/json'
require 'json'

class CSAWebApp < Sinatra::Base
  set :public_folder, 'public'

  # Load the CSA Advisor class
  class CSAAdvisor
    attr_reader :ecological_zones, :smartness_levels, :cis_services

    def initialize
      setup_data
    end

    private

    def setup_data
      @ecological_zones = {
        "Southern Belt" => {
          climate_risks: ["Floods", "Erratic rainfall", "Prolonged drought"],
          value_chains: ["Maize", "Vegetables", "Cocoa"]
        },
        "Middle Belt" => {
          climate_risks: ["Dry spells", "Erratic rainfall", "Floods"],
          value_chains: ["Maize", "Rice", "Yam", "Cocoa", "Poultry"]
        },
        "Northern Belt" => {
          climate_risks: ["Prolonged drought", "Heatwaves", "Flash floods"],
          value_chains: ["Maize", "Rice", "Cowpea", "Soybean", "Yam", "Goat"]
        }
      }

      @smartness_levels = {
        "Maize" => {
          type: "Triple-win AMP",
          practices: {
            "Low" => ["Organic fertilizer", "Cereal-legume integration", "BSF technology"],
            "Intermediate" => ["Organic fertilizer", "Inorganic fertilizers", "Integrated Pest Management"],
            "Medium" => ["IPM", "Agroforestry systems", "Climate-smart varieties"],
            "Full" => ["IPM", "Improved irrigation", "Agroforestry systems", "Smart varieties"]
          }
        },
        "Vegetables" => {
          type: "Double-win AP",
          practices: {
            "Low" => ["Drought-tolerant varieties", "IPM", "Diversified livestock"],
            "Intermediate" => ["Smart varieties", "Bioproducts", "Organic fertilizer"],
            "Medium" => ["Smart varieties", "IPM", "Improved irrigation"],
            "Full" => ["Complete integration", "Advanced irrigation", "Full IPM suite"]
          }
        }
      }

      @cis_services = {
        "Southern Belt" => ["Seasonal forecasts", "Daily rainfall alerts", "Onset predictions"],
        "Middle Belt" => ["Dry spell advisories", "Flood warnings", "Seasonal outlooks"],
        "Northern Belt" => ["Drought alerts", "Heatwave warnings", "Rainfall predictions"]
      }
    end
  end

  # Initialize the advisor
  before do
    @advisor = CSAAdvisor.new
  end

  # Routes
  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end

  get '/api/zones' do
    json @advisor.ecological_zones.keys
  end

  get '/api/risks/:zone' do
    zone = params[:zone]
    json @advisor.ecological_zones[zone][:climate_risks]
  end

  get '/api/value-chains/:zone' do
    zone = params[:zone]
    json @advisor.ecological_zones[zone][:value_chains]
  end

  post '/api/recommendations' do
    payload = JSON.parse(request.body.read)

    ecology = payload['zone']
    value_chain = payload['valueChain']
    investment = payload['investment']
    risks = payload['risks']

    # Calculate risk score
    risk_score = calculate_risk_score(risks)

    # Generate recommendations
    recommendations = {
      profile: {
        ecology: ecology,
        value_chain: value_chain,
        investment: investment,
        risk_score: risk_score
      },
      practices: @advisor.smartness_levels[value_chain]&.dig(:practices, investment) || [],
      cis_services: @advisor.cis_services[ecology],
      addons: ["Minimum tillage", "Intercropping", "Improved postharvest tools"]
    }

    json recommendations
  end

  private

  def calculate_risk_score(risks)
    score = 0
    risks.each do |risk, severity|
      score += severity.to_i if severity.to_i > 0
    end
    score
  end

  run! if app_file == $0
end
