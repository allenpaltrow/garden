#!/usr/bin/env ruby
require 'fileutils'
require 'tempfile'

def replace_in_file(filename,oldvalue,newvalue)
  temp_file = Tempfile.new(File.basename(filename))
  
  contents = File.read(filename)
  changed_contents = contents.gsub(oldvalue,newvalue).gsub(oldvalue.downcase,newvalue.downcase)
  temp_file.print(changed_contents)
  temp_file.close
  FileUtils.mv(temp_file.path, filename)
end


if ARGV.count!=2
  puts "Usage: rename_rails3 <Oldname> <Newname>"
  exit 1
end
oldname = ARGV[0]
newname = ARGV[1]

other_files = [".rvmrc", "config.ru", "Rakefile"].select {|other| File.exists?(other) }

targets = Dir['**/*.{erb,haml,rb,sh,yml}'] + other_files
targets.each do |target|
  puts target
  replace_in_file(target,oldname,newname)
end