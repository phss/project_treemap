require 'rubygems'
require 'sinatra'
require 'csv'
require 'json'
require 'iconv'
require 'roo'

use Rack::Auth::Basic do |username, password|
      username == ENV['MY_SITE_USERNAME'] && password == ENV['MY_SITE_SECRET']
end

# From lighter (Done) to darker (Not Estimated)
COLORS = {
  "green" => "'#CAF6D8', '#96EEB0', '#57E482', '#2CDD61', '#1DAF49'",
  "blue" => "'#BDEFEF', '#8CE3E3', '#52D5D5', '#30C5C5', '#249494'",
  "orange" => "'#FFE9D6', '#FFC799', '#FFA962', '#FF841F', '#E06500'"
}

# Webapp

get '/' do
  @available_files = Dir.glob("files/*.csv").map { |f| File.basename(f, ".*") }

  erb :instructions
end

get '/test' do
    erb :test
end
get '/map/:phase' do
  @phase = params[:phase]
  @color_scheme = COLORS[params.fetch("color", "green")]
  @map_mode = params.fetch("map_mode", "squarify")
  @captions = params.fetch("captions", "true")

  erb :map
end

get '/upload' do
    erb :upload
end

post '/upload' do
    tempfile = params[:file][:tempfile] 
    filename = params[:file][:filename] 
    FileUtils.cp(tempfile.path, "tmp/#{filename}")
    puts Dir.entries("tmp")
    xls = Roo::Excelx.new("tmp/#{filename}")
    if xls.sheets.size > 1
        xls.sheets.each{ |sheet|
            xls.to_csv("files/#{sheet}.csv", "#{sheet}")
        }
    else
        xls.to_csv("files/#{filename}.csv")
    end
    puts Dir.entries("files")
    FileUtils.rm(filename)
end

get '/:phase.json' do
  # Hackily parse the stories from a csv file and transfom the rows
  # into a D3 treemap compatible json object.

  @phase = params[:phase]
  csv_file = "files/#@phase.csv"

  all_stories = CSV.readlines(csv_file).drop(1).map do |row|

    status = row[4]
    status = "Not Started" if status.nil?
    risk = row[5]
    estimate = row[3]
    if int?(estimate)
      estimate = row[3].to_i
    else
      estimate = 0
    end
  
    Story.new(row[0], row[2], estimate, status, risk)
  end

  root = tree_node_for(@phase)
  
  all_stories.delete_if {|x| x.name.nil? }.group_by(&:status).each do |status, status_stories|
    status_json = tree_node_for(status)
  
    status_stories.group_by(&:category).each do |category, stories|
      stories.sort!{ |x, y| x.size_for_map <=> y.size_for_map }
      stories.each do |story|
        story_json = { "name" => story.description, "size" => story.size_for_map, "risk" => story.risk }
  
        status_json["children"] << story_json
      end
    end
  
    root["children"] << status_json
  end

  content_type :json
  root.to_json
end

# "Model"

class Story
  attr_reader :category, :status, :estimate, :risk, :name

  def initialize(category, name, estimate, status, risk)
    @category, @name, @estimate, @status, @risk = category, name, estimate, status, risk
  end

  def description
    "[#@status] #@category - #@name (#@estimate)"
  end
  
  def size_for_map
    4 * (estimate + 1)
  end


end


# Utils

def tree_node_for(name)
  {
    "name" => name,
    "children" => []
  }
end

def int?(str)
    Integer(str) rescue false
end
