Feature: Generate Extjs Install and Scaffold
  In order to use extjs as a scaffold replacement
  As a user of Rails3 and extjs4
	I would like to generate an extjs scaffold
	
	Scenario: Generate ExtJs Scaffold
    When I run `rails new test_app`
		And I cd to "test_app"
    Then the following files should exist:
			| Gemfile |
      | app/assets/javascripts/application.js |
			| app/assets/stylesheets/application.css |
		And I append to "Gemfile" with:
			"""
			gem "haml"
			gem "kaminari", "~> 0.13.0"
			gem "extjs_renderer", "~> 0.1.0"
			gem 'extjs_scaffold', :path => '../../../'
			
			"""
		And I overwrite "app/views/layouts/application.html.erb" with:
			"""
			<!DOCTYPE html>
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
			"""
		And I overwrite "app/assets/javascripts/application.js" with:
			"""
			//= require_self
			//= require_tree ./ux
			//= require_tree ./util
			//= require_tree ./model
			//= require_tree ./store
			//= require_tree ./view
			//= require_tree ./controller
			//= require_tree .
			"""
		And I install extjs in "test_app"
		Then the following files should exist:
			| public/extjs/bootstrap.js |
			| public/extjs/ext-all-debug.js |
		And I run `bundle install`
		Then the output should contain:
		"""
		Your bundle is complete!
		"""
		And I run `rails g extjs_scaffold:install`
		Then the following files should exist:
			| app/assets/javascripts/TestApp.js |
		And I run `rails g extjs_scaffold:scaffold category name:string`
			Then the following files should exist:
				| app/assets/javascripts/controller/Categories.js |
				| app/controllers/categories_controller.rb |
				| app/models/category.rb |
				| app/views/categories/index.html.erb |
				| test/functional/categories_controller_test.rb |
		And I run `rails g extjs_scaffold:scaffold product category:references name:string`
			Then the following files should exist:
				| app/assets/javascripts/controller/Products.js |
				| app/controllers/products_controller.rb |
				| app/models/product.rb |
				| app/views/products/index.html.erb |					
				| test/functional/products_controller_test.rb |
		And I run `rails g scaffold team name:string`
			Then the following files should exist:
				| app/views/products/index.html.erb |					
				| test/functional/teams_controller_test.rb |
		And I append to "Gemfile" with:
			"""
			gem "rspec", "~> 2.7.0"
		  gem "rspec-rails", "~> 2.7.0"
			"""
		And I run `bundle install`
		Then the output should contain:
		"""
		Your bundle is complete!
		"""
		And I run `rails g rspec:install`
		Then the following files should exist:
			| spec/spec_helper.rb |
		And I run `rails g extjs_scaffold:scaffold widget name:string sku:string in_stock:boolean price:decimal last_received_on:date --template_engine=haml`
		Then the following files should exist:
			| app/assets/javascripts/controller/Widgets.js |
			| app/controllers/widgets_controller.rb |
			| app/models/widget.rb |
			| app/views/widgets/index.html.haml |
			| spec/controllers/widgets_controller_spec.rb |
		And I run `rails g extjs_scaffold:scaffold part widget:references name:string quantity:integer --template_engine=haml --reference-fields widget:sku`
		Then the following files should exist:
			| app/assets/javascripts/controller/Parts.js |
			| app/controllers/parts_controller.rb |
			| app/models/part.rb |
			| app/views/parts/index.html.haml |
			| spec/controllers/parts_controller_spec.rb |
		And I run `rake db:migrate`
		Then the output should contain:
		"""
		CreateParts: migrated
		"""
		And I run `rake db:test:prepare`
		And I run `ruby -Itest test/functional/categories_controller_test.rb`
		Then the output should contain:
		"""
		0 failures, 0 errors, 0 skips
		"""
		And I run `ruby -Itest test/functional/products_controller_test.rb`
		Then the output should contain:
		"""
		0 failures, 0 errors, 0 skips
		"""
		And I run `rspec spec`
		Then the output should contain:
		"""
		0 failures
		"""