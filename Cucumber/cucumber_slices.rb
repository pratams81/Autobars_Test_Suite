require 'optparse'
require 'thread'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby cucumber_slices.rb [options] file_0 .. file_n
  \tfile parameters can use globs"

  opts.on("-n", "--number NUMBER", "Specify the number of parallel instances") do |num|
    options[:number] = num.to_i
  end

  opts.on("-o", "--options OPTIONS", "Specify additional options, passed to Cucumber") do |o|
    options[:options] = o
  end
end.parse!

# Default to sequential if no parallelicity value passed
options[:number] = options[:number] || 1
options[:options] = options[:options] || ''

raise OptionParser::MissingArgument unless ARGV.length > 0

$printex = Mutex.new

# pp - parallel print
def pp(*args)
  $printex.synchronize {
    puts *args
  }
end

thread_instance_count = 0

number_of_features = ARGV.length
number_of_completed_features = 0

workers = (0...options[:number]).map do
  Thread.new do
    thread_instance_count += 1
    # This value is passed as TEST_ENV_NUMBER
    thread_instance = thread_instance_count

    # ARGV contains all target files, these are guaranteed to be expanded by the ruby runtime
    while ARGV.length > 0
      feature = ARGV.shift
      begin
        cmd = "ruby -S bundle exec cucumber '#{feature}' " + options[:options] + " TEST_ENV_NUMBER=#{thread_instance}"

        pp "#{thread_instance}:Executing #{cmd}"
        result = `#{cmd}`
        pp "\n#{thread_instance}:>>>>>\n" <<
           result <<
           "#{thread_instance}:<<<<<"
      rescue ThreadError
        pp "#{thread_instance}:Thread error occurred for #{feature}\n"
      end

      number_of_completed_features += 1
      pp "~" + ((number_of_completed_features.to_f / number_of_features) * 100.0).round(1).to_s + "% complete\n"
    end
  end
end

workers.map(&:join)
