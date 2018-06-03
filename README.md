# Redis_MTC

Xojo classes to connect to a Redis server.

## Redis\_MTC Usage

There are two classes. The main one, `Redis_MTC`, is meant for use in code. It will connect on instantiation based on standard parameters or those given in the Constructor.

For example:

```
dim r as Redis_MTC

r = new Redis_MTC // no password, localhost, default port
r = new Redis_MTC( "password" )
r = new Redis_MTC( "", "some.address.com" )
r = new Redis_MTC( "", "", 9999 ) // Custom port on localhost
```

__Note__: If the class cannot connect on instantiation, it will raise an Exception.

The other class, `RedisControl_MTC`, is meant to use as a control on a Window or similar. You must call `Connect` and can implement its additional events. It also has `DefaultAddress` and `DefaultPort` that can be filled in at design time through the Inspector.

## Methods and Functions

The class implements the commands that a Redis server understands pretty closely. For details, head over to [their site](http://redis.io).

There are some exceptions where `Redis_MTC` tries to make things clearer. For example, instead of a function called `MSET`, you will find instead `SetMultiple`, and `BITOP` has `BitAnd`, `BitOr`, and `BitXor`. *Almost* everything has been implemented so look around before turning to ...

## Manual Execution

The class does not implement every Redis command so you might need to issue your own. Use `Execute` for this, but be sure to give the command inline (all in the first parameter) or split each part up into the parameters array.

__Note__: There is also an `Exec` method that is part of Redis' transaction system. Don't confuse the two.

For example, if you wanted to ignore the built-in `Set` and issue your own, you might do it in one of these ways:

```
dim r as new Redis_MTC
dim v as variant

v = r.Execute( "SET mykey myvalue EX 3" ) // Inline
v = r.Execute( "SET", "mykey", "myvalue", "EX", "3" )
v = r.Execute( "SET", array( "mykey", "myvalue", "EX", "3" ) )
```

Results from `Execute` are always a Variant and it's up to you to interpret them. In some cases, the `M_Redis` module has functions that can help.

## Pipelines

`Redis_MTC` allows "pipelines", activated through `StartPipelines( cnt )`. Any value greater than zero will activate Pipeline mode. The difference is that commands will be accumulated up to `PipelineCount` and sent at once without waiting for a reply. It's up to you to get the results later by issuing `FlushPipleline` (wait until all the expected results come in and return them at once) or `ReadPipeline` (get any results that might be waiting). `ResultCount` will let you know what's available in the queue.

If you prefer, you can use the `ResponseInPipeline` event to get waiting results. It would be most efficient to use `ReadPipeline` there but you could `FlushPipeline` instead.

Using a Pipeline is more efficient than the send/wait approach, but not as convenient. In tests, regular mode (no pipeline) could handle around 25k SET commands per second on a local server whereas 10 Pipelines could do around 340k per second. Pipeline results are "raw" and it's up to you to match them to the command that was issued to obtain them, and to interpret them. 

Use `StartPipeline( cnt )` to change to Pipeline mode. Once in Pipeline mode, results from individual functions will be meaningless and can be ignored. Use `FlushPipeline( false )` to get the final results and turn off the Pipeline.

Example:

```
dim r as new Redis_MTC
r.StartPipeline( 10 )

for i as integer = 1 to 1000
  call r.Set( "key" + str( i ), "xxx" )
next

dim results() as variant = r.FlushPipeline // Stay in Pipeline mode

//
// Unless there was an error, results will have a Ubound of 999 and
// contain all True values
//

results() = r.FlushPipeline( false ) // Turn off the Pipeline

//
// results will have a Ubound of -1
//
```

__Note__: Due to the implementation of Xojo's classic TCPSocket, there are diminishing returns with higher Pipeline values. You will probably stop seeing a benefit at around 30-50 pipelines with a maximum throughput of around 500k requests per second on a local server.

## Errors

When not using a Pipeline, errors returned by the Redis server will be raised as `RedisException`. Where possible and appropriate, using a key that does not exist will result in a `KeyNotFoundException`.

In Pipeline mode, a `RedisException` will be included in the array of results, and no exceptons will be raised.

## Examples

The project comes with unit tests for each function. Explore those to get an idea of how to use them.

## Redis Server

The `RedisServer_MTC` class will let you set up a redis server within your app quickly. You just need to give it the redis-server executable that you can download from the links below, or get from within this project. The former will ensure the latest versions, of course.

The Server GUI project will run an instance of redis-server through a GUI for convenience. The Redis Server apps are available for download within the GitHub project.

There are two "hidden" features of the app. First, holding down the option or alt key while pressing "Stop" will immediately kill the instance of redis-server without giving it an opportunity to clean up. That should be used sparingly. Second, you can drop a ".conf" or ".config" file directly onto the window to start (or restart) redis-server with it.

## Who Did This?

This project was designed and implemented by:

- Kem Tekinay (ktekinay at mactechnologies.com)

## External Resources

### redis-server

The Mac binary was compiled from source downloaded from [the Redis website](https://redis.io). The Windows binary was downloaded directly from 

[https://github.com/MicrosoftArchive/redis/releases](https://github.com/MicrosoftArchive/redis/releases)

### Redis Server Icon

The icon was available on [IconFinder](https://www.iconfinder.com/icons/1886359/archive_archives_database_files_hosting_server_storage_icon#size=16) and designed by [DinosoftLabs](https://www.iconfinder.com/dinosoftlabs).

## Release Notes

**1.2** (__)

- Added `Redis_MTC.StartMonitor` for Monitor mode.
- `RedisServer_MTC.Kill` is less fragile.

**1.1.1** (Jun. 3, 2018)

- Fixed harnesses for Windows.

**1.1** (Jun. 2 2018)

- Added RedisServer\_MTC and unit tests.
- Added Server GUI project.
- Added `Shutdown`.
- Updated unit tests to work on servers with higher latency.

**1.0** (Jan. 22, 2018)

- Initial release.
