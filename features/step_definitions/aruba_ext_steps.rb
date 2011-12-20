Given /^I install extjs in "([^"]*)"$/ do |app_name|
  src = File.expand_path('../../../resources/extjs', __FILE__ )
  dest = File.expand_path("../../../#{@dirs.first}/#{app_name}/public", __FILE__ )
  FileUtils.cp_r src, dest
end

