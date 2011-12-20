Feature: Generating things
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
			gem "kaminari"
			gem "extjs_renderer", "~> 0.1.0"
			"""
		And I install extjs in "test_app"
		And I cd to "public"
		Then the following files should exist:
			| extjs/bootstrap.js |
			| extjs/ext-all-debug.js |
		And I cd to "../"
		Then I run `bundle install`
		Then the output should contain:
		"""
		Your bundle is complete!
		"""