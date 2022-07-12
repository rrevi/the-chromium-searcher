#!/usr/bin/env ruby

require 'optparse'
require 'async'

options = {
    # the following at the default options value
    :recursive => false,
    :method => 'ractor',
    :skip_output => false
}
search_method_options = { 
    'serial' => 'serial',
    'fiber' => 'fiber',
    'ractor' => 'ractor' 
}

option_parser = OptionParser.new do |opts|
    opts.banner = "Usage: cr.rb [options] search_term search_directory_path"

    opts.on('-r', '--recursive', 'Recursively search in files in sub-directories') do
        options[:recursive] = true
    end

    opts.on('--method METHOD', search_method_options, 'Method to search by: serial (one file at a time), fiber (multiple files at the same time), or ractor (multiple files at the same time)') do |method|
        options[:method] = method
    end

    opts.on('--skip-output', 'Do not print to stdout the results of the search (this option was made to benchmarking purposes)') do
        options[:skip_output] = true
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

def search_in_file(search_term, file, skip_output)
    File.readlines(file).each do |line|
        if line.include? search_term
            puts "#{file}: #{line}" unless skip_output
        end
    end 
end

def serial_search(search_term, files, skip_output)
    files.each do |file|
        if File.file? file
           search_in_file search_term, file, skip_output
        end
    end
end

def fiber_search(search_term, file, skip_output)
    Async do |task|
        if File.file? file
            search_in_file search_term, file, skip_output
        end
    end
end

def ractor_search(search_term, files, skip_output)
    files.each do |file|
        Ractor.new(file, search_term, skip_output) do |file_in_ractor, search_term_in_ractor, skip_outp|
            if File.file? file_in_ractor
                # we don't re-use the mehod search_in_file here
                # because since every Ractor instance is in it's own thread
                # we cannot access data outside of said thread (like the other thread where main is in)
                File.readlines(file_in_ractor).each do |line|
                    if line.include? search_term_in_ractor
                        puts "#{file_in_ractor}: #{line}" unless skip_outp
                    end
                end
            end
        end
        # notice, not using the Ractor take command here
        # as we are not depending on the Ractor object/thread to return any value for us to use here
    end
end

case options[:method]
when 'serial'
    serial_search arguments[:search_term], files_to_search_in, options[:skip_output]
when 'fiber'
    Async do
        files_to_search_in.each do |file|
            fiber_search arguments[:search_term], file, options[:skip_output]
        end
    end
when 'ractor'
    ractor_search arguments[:search_term], files_to_search_in, options[:skip_output]
end