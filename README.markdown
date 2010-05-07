# ActiveRedis

ActiveModel based object persisting library for [Redis](http://code.google.com/p/redis) key-value database.

## How to start

1. Clone the repository
2. Fetch submodules
3. Install Rails 3 gem (latest preview)
4. Run rake redis:start
5. Run rake console

	>> c = Cat.new :age=>12, :name => "long"
	=> #<Cat:0x1015021f0 @attributes={"name"=>"long", "age"=>"12"}>
	>> c.save
	=> true
	>> Cat.count
	=> 1
	>> Cat.find(1)
	=> #<Cat:0x10121ff78 @attributes={"name"=>"long", "age"=>"12"}, @id=1>


## Other stuff

Check [Persisting Objects in Redis Key-Value Database](http://www.cs.helsinki.fi/u/paksula/misc/redis.pdf) for some design principles of ActiveRedis.

## Contributing

Pull requests are welcome!

For any questions contact [matti.pasula@cs.helsinki.fi](mailto:matti.pasula@cs.helsinki.fi)
