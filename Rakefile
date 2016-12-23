require "bundler/gem_tasks"
require "listen"
require "byebug"
require "colorize"
require "open3"

task :default => :test

# Basic logging utility methods
def log(msg, color: "default", io: $stdout, &block)
  io.puts "#{Time.now.strftime('%Y/%m/%d %H:%M:%S').colorize(:light_black)} #{msg.to_s.colorize(color.to_sym)}"
end

def log_info(msg, io: $stdout, &block)
  log(msg, color: "cyan", &block)
end

def log_error(msg, &block)
  log(msg, color: "red", io: $stderr, &block)
end

def log_error_stack(err, &block)
  msg = "#{err.to_s}\n\t#{err.backtrace[0...3].join("\n\t")}"
  log_error(msg, &block)
end

def log_warning(msg, &block)
  log(msg, color: "yellow", io: $stderr, &block)
end

desc "Run the unit tests."
task :test do
  test_files = (ENV.has_key?("TEST") ? [ENV["TEST"]] : Dir["test/**/*_test.rb"]).join(" ")
  cmd = "ruby -I\".:lib:test\" -e \"ARGV.each { |f| require f }\" #{test_files}"
  log_info "Running tests..."
  system(cmd)
  puts ""
end

namespace :test do
  desc "Automatically rerun tests when files change."
  task :auto do
    ignore = /\.byebug_history|parser\.output/
    listener = Listen.to('.', 'lib', 'test', ignore: ignore) do |modified, added, removed|
      added.each { |path| log_warning "#{path} was added." }
      modified.each { |path| log_warning "#{path} was modified." }
      removed.each { |path| log_warning "#{path} was removed." }
      ["test"].each { |t| Rake::Task[t].reenable }
      Rake::Task[:test].invoke
    end

    trap("INT") {
      puts ""
      log_info "Stopping auto testing."
      listener.stop
      exit 0
    }

    begin
      listener.start
      Rake::Task[:test].invoke
    rescue => e
      log_error_stack(e)
      log_warning "Waiting for files to change."
    end

    sleep
  end
end
