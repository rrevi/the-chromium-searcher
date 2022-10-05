#!/usr/bin/env ruby

require 'optparse'
require 'async'

options = {
    # the following at the default options value
    :recursive => false,
    :method => 'ractor'
}
search_method_options = { 
    'serial' => 'serial',
    'fiber' => 'fiber',
    'ractor' => 'ractor' 
}

option_parser = OptionParser.new do |opts|
    opts.banner = "Usage: cr.rb [options] search_term search_directory_path"

    opts.on('-r', '--recursive', 'Recursively search files in sub-directories') do
        options[:recursive] = true
    end

    opts.on('--method METHOD', search_method_options, 'Method to search by: serial (one file at a time), fiber (multiple files at the same time), or ractor (multiple files at the same time)') do |method|
        options[:method] = method
    end

    opts.on('-h', '--help', "Prints this help") do
        puts opts
        exit
    end
end

option_parser.parse!

arguments = {}

arguments[:search_term] = ARGV.shift
if arguments[:search_term].nil? or arguments[:search_term].empty?
    puts "missing argument: NO search term provided"
    exit
end

arguments[:search_directory_path] = ARGV.shift
if arguments[:search_directory_path].nil? or arguments[:search_directory_path].empty?
    puts "missing argument: NO search directory path provided"
    exit
end

if Dir.exists? arguments[:search_directory_path]
    if options[:recursive]
        files_to_search_in = Dir.glob("#{arguments[:search_directory_path]}/**/*")
    else
        files_to_search_in = Dir.glob("#{arguments[:search_directory_path]}/*")
    end
else
    files_to_search_in = [arguments[:search_directory_path]]
end

def ignore_file?(file)
  skip_locations = ["bin/", "tmp/", "_site/", "log/", "node_modules/"]
  skip_locations.each do |skip_location|
    if File.directory? file
      return true
    elsif file.include? skip_location
      return true
    end
  end

  return false
end

files_to_search_in.reject! { |file| ignore_file? file }

def search_in_file(search_term, file)
    File.readlines(file).each do |line|
        if line.include? search_term
            puts "#{file}: #{line}"
        end
    end 
end

def serial_search(search_term, files)
    files.each do |file|
        search_in_file search_term, file
    end
end

def fiber_search(search_term, file)
    Async do |task|
        search_in_file search_term, file
    end
end

def ractor_search(search_term, files)
    files.each do |file|
        Ractor.new(file, search_term) do |file_in_ractor, search_term_in_ractor|
            # we don't re-use the mehod search_in_file here
            # because since every Ractor instance is in it's own thread
            # we cannot access data outside of said thread (like the other thread where main is in)
            File.readlines(file_in_ractor).each do |line|
                if line.include? search_term_in_ractor
                    puts "#{file_in_ractor}: #{line}"
                end
            end
        end
        # notice, not using the Ractor take command here
        # as we are not depending on the Ractor object/thread to return any value for us to use here
    end
end

case options[:method]
when 'serial'
    serial_search arguments[:search_term], files_to_search_in
when 'fiber'
    Async do
        files_to_search_in.each do |file|
            fiber_search arguments[:search_term], file
        end
    end
when 'ractor'
    ractor_search arguments[:search_term], files_to_search_in
end