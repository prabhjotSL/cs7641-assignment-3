task :console do
  require 'irb'
  require 'irb/completion'
  require 'java'
  require './vendor/burlap.jar'
  require './vendor/jfreechart-1.0.17'
  require './vendor/commons-math3-3.2'
  require './vendor/jcommon-1.0.21.jar'
  require 'bundler'
  Bundler.require

  def reload!
    Dir['./lib/**/*.rb'].each {|_| load _ }
  end

  reload!
  ARGV.clear
  IRB.start
end
