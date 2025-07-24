puts "=== PUMA CONFIG DEBUG ==="
puts "RAILS_MAX_THREADS: #{ENV['RAILS_MAX_THREADS'].inspect}"
puts "PORT: #{ENV['PORT'].inspect}"
puts "WEB_CONCURRENCY: #{ENV['WEB_CONCURRENCY'].inspect}"

threads_count = ENV.fetch("RAILS_MAX_THREADS", 3).to_i
puts "Calculated threads_count: #{threads_count.inspect}"

port_number = ENV.fetch("PORT", 3000).to_i
puts "Calculated port: #{port_number.inspect}"
puts "========================="
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

preload_app!

port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
