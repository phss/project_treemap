require 'csv'
require 'rubygems'
require 'treemap'

class Story
  attr_reader :category, :status, :estimate

  def initialize(category, name, estimate, status)
    @category, @name, @estimate, @status = category, name, estimate, status 
  end

  def description
    "[#@status] #@category - #@name"
  end

end

all_stories = CSV.readlines('release.csv').map do |row|
  status = row[3]
  status = "not started" if status.nil?

  estimate = row[2]
  if row[2].nil?
    estimate = 1
  else
    estimate = row[2].to_i + 1 # accounting for story of size 0
  end

  Story.new(row[0], row[1], estimate, status)
end

root = Treemap::Node.new

all_stories.group_by(&:status).each do |status, status_stories|
  status_stories.group_by(&:category).each do |category, stories|
    status_node = Treemap::Node.new(:label => "")

    stories.each do |story|
      status_node.new_child(:size => story.estimate, :label => story.description)
    end

    root.add_child(status_node)
  end
end


output = Treemap::HtmlOutput.new do |o|
  o.width = 800
  o.height = 600
  o.center_labels_at_depth = 1
end

puts output.to_html(root)
