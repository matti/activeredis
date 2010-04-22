require 'spec/rake/spectask'

task :default => :spec

desc "Run tests and manage server start/stop"
task :spec => ["redis:start", "spec:run", "redis:stop"]

namespace :spec do
  desc "Run all specs in spec directory (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:run) do |t|
    t.spec_opts = ['--options', "spec/spec.opts"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end
end

namespace :redis do
  desc "Build redis"
  task :build do
    Dir.chdir("redis") do
      system("make")
    end
  end
  
  REDIS_DIR = File.expand_path(File.join(".."), __FILE__)
  puts "using #{REDIS_DIR} as redis directory"
  REDIS_CNF = File.join(REDIS_DIR, "spec", "redis.conf")
  puts "using #{REDIS_CNF} as redis configuration file"
  REDIS_PID = File.join(REDIS_DIR, "tmp", "redis_db", "redis.pid")
  puts "using #{REDIS_PID} as redis pid file"

  desc "Start the Redis server"
  task :start do
    unless File.exists?("redis/redis-server")
      puts "You need to build redis first! use redis:build task first."
      raise "You need to build redis first! use redis:build task first."
    end
    unless File.exists?(REDIS_PID)
      system "redis/redis-server #{REDIS_CNF}"
      puts "Started redis server with pid #{File.read(REDIS_PID)}"
    end
  end

  desc "Stop the Redis server"
  task :stop do
    if File.exists?(REDIS_PID)
      pid = File.read(REDIS_PID)
      puts "Stopping redis server with pid #{pid}"
      system "kill #{pid}"
      system "rm #{REDIS_PID}"
    end
  end
end
