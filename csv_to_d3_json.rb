require 'csv'
require 'json'

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

def json_for(name)
  {
    "name" => name,
    "children" => []
  }
end

all_stories = CSV.readlines('release.csv').drop(1).map do |row|
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

d3_json = {
  "name" => "release",
  "children" => []
}

all_stories.group_by(&:status).each do |status, status_stories|
  status_json = json_for(status)

  status_stories.group_by(&:category).each do |category, stories|

    stories.each do |story|
      story_json = { "name" => story.description, "size" => story.size_for_map }

      status_json["children"] << story_json
    end
  end

  d3_json["children"] << status_json
end

File.open("release_d3.json","w") do |f|
  f.write(d3_json.to_json)
end
