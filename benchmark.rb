require 'benchmark'

require 'lib/active_redis'

class Post < ActiveRedis::Base

end


LOREM = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

Benchmark.bm(26) do |x|

  [1000,5000,10000].each do |howmany|
  
    x.report("Create #{howmany} posts: ") do
      howmany.times do |t|
        p = Post.new({ :topic => "a"*(8+rand(55)),
                        :author => "a"*(8+rand(55)),
                        :content => LOREM*(8+rand(55))})
        p.save
      end
    end
      
    x.report("Count posts: ") do
      Post.count
    end
    
    x.report("Find posts: ") do
      howmany.times do |t|
        p = Post.find(t+1)
      end
    end

    x.report("Update (find+save) posts: ") do
      howmany.times do |t|
        p = Post.find(t+1)
        p.save
      end
    end
    
    puts
  end
  
end

