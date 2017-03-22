# encoding: UTF-8

# $LOAD_PATH.unshift(File.dirname(__FILE__))
# $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rake/testtask'

Rake::TestTask.new do |t|
  # t.libs << "lib"
  t.test_files = FileList["test/**/test_*.rb"].exclude("test/test_helper.rb")
  t.verbose = true
end
