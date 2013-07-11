require 'sinatra'
require 'csv'
require 'json'

# Webapp

get '/map/:phase' do
  @phase = params[:phase]

  erb :map
end

get '/:phase.json' do
  @phase = params[:phase]
  csv_file = "#@phase.csv"

  all_stories = CSV.readlines(csv_file).drop(1).map do |row|
    status = row[3]
    status = "Not Started" if status.nil?
  
    estimate = row[2]
    if row[2].nil?
      estimate = 0
    else
      estimate = row[2].to_i
    end
  
    Story.new(row[0], row[1], estimate, status)
  end

  root = tree_node_for(@phase)
  
  all_stories.group_by(&:status).each do |status, status_stories|
    status_json = tree_node_for(status)
  
    status_stories.group_by(&:category).each do |category, stories|
  
      stories.each do |story|
        story_json = { "name" => story.description, "size" => story.size_for_map }
  
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
  attr_reader :category, :status, :estimate

  def initialize(category, name, estimate, status)
    @category, @name, @estimate, @status = category, name, estimate, status 
  end

  def description
    "[#@status] #@category - #@name (size #@estimate)"
  end
  
  def size_for_map
    estimate + 1
  end

end


# Utils

def tree_node_for(name)
  {
    "name" => name,
    "children" => []
  }
end
