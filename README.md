# project_treemap

Experiment in representing a list of stories for a project as a treemap.

It's a very simple and hacky Sinatra app using D3's treemap layout (https://github.com/mbostock/d3/wiki/Treemap-Layout).

## Usage

Run it with:

    ruby app.rb
    
In order to visualize a list of stories for your project, drop a CSV file with the story list on the root directoy of the app.

You should be able to navigate to http://localhost:4567/ (or whatever is the Sinatra port for you) and see the file listed there. And example of the file format can be seen here: https://github.com/moonpxi/project_treemap/blob/master/story_list_example.csv

### Customization

You can customize two aspects of the output by setting specific params in the request URL: the base color and the treemap mode. 

Colors (param: color):

* green (default)
* orange
* blue

Treemap mode (param: map_mode, options fron https://github.com/mbostock/d3/wiki/Treemap-Layout#wiki-mode):

* squarify (default)
* slice
* dice
* slice-dice

Examples:

    http://localhost:4567/map/story_list_example?color=orange # Everything orange
    http://localhost:4567/map/story_list_example?map_mode=slice # From left to right
    http://localhost:4567/map/story_list_example?color=orange&map_mode=slice # Orange AND from left to right!!!
    

## Dependency

* Sinatra
