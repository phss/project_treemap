# project_treemap

Experiment/hack in representing a list of stories for a project as a treemap.

It's a very simply Sinatra app using D3's treemap layout (https://github.com/mbostock/d3/wiki/Treemap-Layout).

## Dependency

* Sinatra

## Usage

Run it with:

    ruby app.rb
    
In order to visualize a list of stories for your project, drop a CSV file with the story list on the root directoy of the app.

You should be able to navigate to http://localhost:4567/ (or whatever is the Sinatra port for you) and see the file listed there.

