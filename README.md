# ExtjsScaffold

Rails 3.2 Scaffold generator for Extjs 4.1

## Usage

### Install
1) Add extjs_scaffold, extjs_render, and pagination to Gemfile
	
	gem 'extjs_scaffold'
	gem 'extjs_renderer'
	gem "kaminari"

	or
	
	gem 'extjs_scaffold'
	gem 'extjs_renderer'
	gem "will_paginate", "~> 3.0.0"
	
2) bundle install

3) Install Sencha Extjs 4 into public
	
	public/extjs

4) Add Extjs to app/views/layouts/application.html.erb

	<html>
	<head>
	  <title>TestApp</title>
	  <%= stylesheet_link_tag    "/extjs/resources/css/ext-all.css" %>
	  <%= stylesheet_link_tag    "application" %>
	  <%= javascript_include_tag "/extjs/ext-all-debug.js" %>
	  <%= javascript_include_tag "application" %>
	  <%= csrf_meta_tags %>
	</head>
	<body>

	<%= yield %>

	</body>
	</html>

5) Add Extjs MVC structure app/assets/javascripts/application.js

		//= require_self
		//= require_tree ./ux
		//= require_tree ./util
		//= require_tree ./model
		//= require_tree ./store
		//= require_tree ./view
		//= require_tree ./controller
		//= require_tree .

6) Run the install generator

	rails generate extjs_scaffold:install
	
Which will create an Extjs application file and the scaffold ux files. By default the application file and the application name are set to the rails app name.  

These can be customized using the --file-name and --app-name class options

	rails generate extjs_scaffold:install --file-name=ExtjsApp --app-name=TestApp
	
	or
	
	rails generate extjs_scaffold:install -n=ExtjsApp -a=TestApp
	
### Scaffold

	rails generate extjs_scaffold:scaffold widget name:string
	
	rake db:migrate
	
Class Options

If the file or app name were customized during the install, they must be passed into the scaffold generator:

	rails generate extjs_scaffold:scaffold widget name:string -n=ExtjsApp -a=TestApp

Reference field lookups default to a 'name' field in the parent table. This can be customized by setting the --reference_fields option:

	rails generate extjs_scaffold:scaffold widget category:references name:string --reference_fields category:category_type
	
	Which would look for a 'category_type' field in the category table
	
Pagination defaults to Kaminari.  To use Will Paginate, set the --pagination option:

	rails generate extjs_scaffold:scaffold widget name:string --pagination=will_paginate
	
Views support erb (default) and haml

Controller tests for TestUnit and Rspec are generated

ORM is generated using Rails::Generators::ScaffoldGenerator and then injected with additional methods