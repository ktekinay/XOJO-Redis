#tag Class
Protected Class RedisTests
Inherits TestGroup
	#tag Event
		Sub Setup()
		  self.Redis = nil
		  
		  dim r as Redis_MTC
		  
		  #pragma BreakOnExceptions false
		  try
		    r = new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  catch err as RuntimeException
		    r = new Redis_MTC( "pw" )
		    r.ConfigSet Redis_MTC.kConfigRequirePass, ""
		    r = new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  end try
		  #pragma BreakOnExceptions default
		  
		  call r.Delete( r.Scan( "xut:*" ) )
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AppendTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual 1, r.Append( "xut:key", "h" )
		  Assert.AreSame "h", r.Get( "xut:key" )
		  
		  Assert.AreEqual 2, r.Append( "xut:key", "i" )
		  Assert.AreSame "hi", r.Get( "xut:key" )
		  
		  r.Delete "xut:key"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AuthTest()
		  //
		  // A dangerous test that we do not perform unless needed
		  //
		  return
		  
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  r.ConfigSet Redis_MTC.kConfigRequirePass, "pw"
		  
		  r = nil
		  
		  #pragma BreakOnExceptions false
		  try
		    r = new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		    Assert.Fail "Created unauthenticated object"
		  catch err as RuntimeException
		    Assert.Pass "Created authenticated object"
		  end try
		  #pragma BreakOnExceptions default
		  
		  r = nil
		  r = new Redis_MTC( "pw" )
		  Assert.IsNotNil r
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BinaryDataTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  dim data as string = ChrB( &b10101010 )
		  data = data + data // Impossible in UTF8
		  Assert.IsFalse Encodings.UTF8.IsValidData( data )
		  
		  Assert.IsTrue r.Set( "xut:key", data )
		  
		  dim actual as string = r.Get( "xut:key" )
		  Assert.AreSame data, actual
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BitCountTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key", "abc123", 100 )
		  Assert.AreEqual 20, r.BitCount( "xut:key" ), "Full"
		  Assert.AreEqual 6, r.BitCount( "xut:key", 0, 1 ), "Partial"
		  
		  r.Delete "xut:key"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BitFieldIncrementByTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual CType( 0, Int64), r.BitFieldSet( "xut:key", r.kTypeUInt32, 0, 0 )
		  Assert.AreEqual CType( 5, Int64 ), r.BitFieldIncrementBy( "xut:key", "u8", 0, 5 )
		  Assert.AreEqual CType( 7, Int64 ), r.BitFieldIncrementBy( "xut:key", "u8", 0, 2, false, Redis_MTC.Overflows.Sat )
		  Assert.Message "With Overflow: " + &uA + ReplaceLineEndings( r.LastCommand.Trim, &uA ).ToText
		  
		  r.Delete "xut:key"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BitFieldSetGetTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  const kZero as Int64 = 0
		  
		  Assert.AreEqual kZero, r.BitFieldSet( "xut:key","u8", 0, &b10101010 ), "Set 1"
		  Assert.AreEqual CType( &b0101, Int64 ), r.BitFieldSet( "xut:key", "u4", 1, 1 ), "Set 2"
		  Assert.AreEqual CType( &b10001010, Int64 ), r.BitFieldGet( "xut:key", r.kTypeUInt8, 0 ), "Get"
		  
		  r.Delete "xut:key"
		  
		  Assert.AreEqual kZero, r.BitFieldSet( "xut:key", "u32", 0, &hFFFFFFFF )
		  Assert.AreEqual CType( &hFF, Int64 ), r.BitFieldSet( "xut:key", "u8", 1, 0, true )
		  Assert.AreEqual CType( &hFF00FFFF, Int64 ), r.BitFieldGet( "xut:key", "u32", 0 )
		  Assert.AreEqual CType( &hFFFF, Int64 ), r.BitfieldGet( "xut:key", "u16", 1, true )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BitOpTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key1", "foobar" )
		  Assert.IsTrue r.Set( "xut:key2", "abcdef" )
		  
		  Assert.AreEqual 6, r.BitAnd( "xut:key3", "xut:key1", "xut:key2" ), "AND cnt"
		  Assert.AreEqual "`bc`ab", r.Get( "xut:key3" ), "AND Get"
		  
		  Assert.AreEqual 6, r.BitOr( "xut:key3", "xut:key1", "xut:key2" ), "OR cnt"
		  Assert.AreEqual "goofev", r.Get( "xut:key3" ), "OR Get"
		  
		  Assert.AreEqual 6, r.BitXor( "xut:key3", "xut:key1", "xut:key2" ), "XOR cnt"
		  Assert.AreEqual "070D0C060414", EncodeHex( r.Get( "xut:key3" ) ), "XOR Get"
		  
		  Assert.AreEqual 6, r.BitNot( "xut:key3", "xut:key1" ), "NOT cnt"
		  Assert.AreEqual "9990909d9e8d", EncodeHex( r.Get( "xut:key3" ) ), "NOT Get"
		  
		  call r.Delete( r.Scan( "xut:*" ) )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BitPosTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key", ChrB( &b10101010 ) + ChrB( &b01010101 ), 1000 )
		  Assert.AreEqual 0, r.BitPos( "xut:key", 1 ), "1 in entire"
		  Assert.AreEqual 1, r.BitPos( "xut:key", 0 ) , "0 in entire"
		  Assert.AreEqual 9, r.BitPos( "xut:key", 1, 1 ), "1 starting at second byte"
		  Assert.AreEqual 8, r.BitPos( "xut:key", 0, 1 ), "0 starting at second byte"
		  Assert.AreEqual 0, r.BitPos( "xut:key", 1, 0, 0 ), "1 in first byte"
		  Assert.AreEqual 9, r.BitPos( "xut:key", 1, 1, 1 ), "1 in second byte"
		  
		  r.Delete "xut:key"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CommandTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  dim cnt as integer = r.CommandCount
		  #pragma BreakOnExceptions false
		  dim commands as Dictionary = r.Command
		  #pragma BreakOnExceptions default
		  
		  Assert.AreEqual cnt, commands.Count
		  Assert.IsTrue commands.HasKey( "GET" )
		  
		  #pragma BreakOnExceptions false
		  commands = r.CommandInfo( "GET", "SET" )
		  #pragma BreakOnExceptions default
		  
		  Assert.AreEqual 2, commands.Count
		  Assert.IsTrue commands.Lookup( "GET", nil ) isa M_Redis.CommandSpec
		  
		  #pragma BreakOnExceptions false
		  commands = r.CommandInfo( "xososos" )
		  #pragma BreakOnExceptions default
		  
		  Assert.IsNil commands
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ConfigGetTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  dim values as Dictionary = r.ConfigGet
		  Assert.IsNotNil values
		  
		  values = r.ConfigGet( "requirepas*" )
		  Assert.AreEqual 1, values.Count
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ConnectTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  #pragma unused r
		  
		  Assert.Pass "Connected"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DBSizeTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  r.SetMultiple( "xut:key1" : "value", "xut:key2" : "value2", "xut:key3" : "value3" )
		  Assert.IsTrue r.DBSize >= 3
		  call r.Delete( r.Scan( "xut:*" ) )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DecrementByTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual -2, r.DecrementBy( "xut:key", 2 )
		  Assert.AreEqual -5, r.DecrementBy( "xut:key", 3 )
		  
		  Assert.IsTrue r.Set( "xut:key", "4", 10 )
		  Assert.AreEqual 1, r.DecrementBy( "xut:key", 3 )
		  
		  r.Delete "xut:key"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DecrementTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual -1, r.Decrement( "xut:key" )
		  Assert.AreEqual -2, r.Decrement( "xut:key" )
		  
		  Assert.IsTrue r.Set( "xut:key", "4", 10 )
		  Assert.AreEqual 3, r.Decrement( "xut:key" )
		  
		  r.Delete "xut:key"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeleteTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key", "value" )
		  r.Delete( "xut:key" )
		  Assert.AreEqual Ctype( -1, Int32 ), r.Keys( "xut:*" ).Ubound
		  
		  Assert.IsTrue r.Set( "xut:key1", "value1" )
		  Assert.IsTrue r.Set( "xut:key2", "value2" )
		  Assert.AreEqual 2, r.Delete( "xut:key1", "xut:key2", "xut:key3" )
		  
		  #pragma BreakOnExceptions false
		  try
		    r.Delete( "xut:key" )
		    Assert.Fail "Did not raise exception"
		  catch err as KeyNotFoundException
		    Assert.Pass "Raised exception"
		  end try
		  #pragma BreakOnExceptions default
		  
		  #pragma BreakOnExceptions false
		  try
		    r.Delete( "xut:key", true )
		    Assert.Pass "Did not raise exception on silent"
		  catch err as KeyNotFoundException
		    Assert.Fail "Raised exception on silent"
		  end try
		  #pragma BreakOnExceptions default
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EchoTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual "hi", r.Echo( "hi" )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ExistsTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key", "value" )
		  Assert.IsTrue r.Exists( "xut:key" )
		  
		  Assert.IsTrue r.Set( "xut:key2", "another" )
		  Assert.AreEqual 2, r.Exists( "xut:key", "xut:key2", "xut:key3" )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ExpireAtTest()
		  dim d as new Date
		  d.TotalSeconds = d.TotalSeconds + 1.0
		  
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key1", "value" )
		  r.ExpireAt "xut:key1", d
		  Assert.IsTrue r.Exists( "xut:key1" ), "Key should exist"
		  Pause 1010
		  Assert.IsFalse r.Exists( "xut:key1" ), "Key should not exist"
		  
		  #pragma BreakOnExceptions false
		  try
		    r.ExpireAt "xut:key1", d
		    Assert.Fail "Key should have expired"
		  catch err as KeyNotFoundException
		    Assert.Pass 
		  end try
		  #pragma BreakOnExceptions default
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ExpireTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key1", "value" )
		  r.Expire "xut:key1", 10
		  Assert.IsTrue r.Exists( "xut:key1" ), "Key should exist"
		  Pause 15
		  Assert.IsFalse r.Exists( "xut:key1" ), "Key should not exist"
		  
		  #pragma BreakOnExceptions false
		  try
		    r.Expire "xut:key1", 1
		    Assert.Fail "Key should have expired"
		  catch err as KeyNotFoundException
		    Assert.Pass "Unknown key"
		  end try
		  #pragma BreakOnExceptions default
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FinishPipelineTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  r.StartPipeline 100
		  
		  for i as integer = 1 to 9
		    call r.Set( "xut:key" + str( i ), "value" )
		  next
		  
		  r = nil
		  
		  r = new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  dim keys() as string = r.Scan( "xut:*" )
		  Assert.AreEqual 8, CType( keys.Ubound, integer )
		  
		  call r.Delete( r.Scan( "xut:*" ) )
		  
		  r.StartPipeline 100
		  
		  for i as integer = 1 to 9
		    call r.Set( "xut:key" + str( i ), "value" )
		  next
		  
		  r.Disconnect
		  
		  call r.Connect
		  
		  keys = r.Scan( "xut:*" )
		  Assert.AreEqual 8, CType( keys.Ubound, integer )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FlushAllTest()
		  //
		  // A dangerous test that we do not perform unless needed
		  //
		  return
		  
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  Assert.IsTrue r.Set( "xut:key", "value" )
		  
		  r.FlushAll
		  Assert.AreEqual Ctype( -1, Int32 ), r.Keys.Ubound
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FlushDBTest()
		  //
		  // A dangerous test that we do not perform unless needed
		  //
		  return
		  
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  Assert.IsTrue r.Set( "xut:key", "value" )
		  
		  r.FlushDB
		  Assert.AreEqual -CType( 1, Int32 ), r.Keys.Ubound
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetRangeTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key", "hi there" )
		  Assert.AreSame "hi there", r.GetRange( "xut:key", 0, 7 )
		  Assert.AreSame "hi there", r.GetRange( "xut:key", 0, 70 )
		  Assert.AreSame "hi", r.GetRange( "xut:key", 0, 1 )
		  Assert.AreSame "there", r.GetRange( "xut:key", 3, 7 )
		  Assert.AreSame "there", r.GetRange( "xut:key", 3, 70 )
		  
		  r.Delete "xut:key"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetSetTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual "", r.GetSet( "xut:key", "a" )
		  Assert.AreEqual "a", r.GetSet( "xut:key", "b" )
		  Assert.AreEqual "b", r.Get( "xut:key" )
		  
		  call r.Delete( "xut:key" )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HashFunctionsTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual 1, r.HSet( "xut:hash", "field1", "value" )
		  Assert.AreEqual 0, r.HSet( "xut:hash", "field1", "newvalue" )
		  Assert.AreEqual "newvalue", r.HGet( "xut:hash", "field1" )
		  Assert.AreEqual 0, r.HSet( "xut:hash", "field1", "xxx", true )
		  Assert.AreEqual "newvalue", r.HGet( "xut:hash", "field1" )
		  Assert.AreEqual 1, r.HSet( "xut:hash", "field2", "value" )
		  
		  Assert.AreEqual 8, r.HStrLen( "xut:hash", "field1" )
		  Assert.AreEqual 0, r.HStrLen( "xut:hash", "field1000" )
		  Assert.AreEqual 0, r.HStrLen( "xut:something", "field1" )
		  
		  dim d as Dictionary = r.HGetAll( "xut:hash" )
		  Assert.AreEqual 2, d.Count
		  
		  dim keys() as string = r.HKeys( "xut:hash" )
		  Assert.AreEqual 1, CType( keys.Ubound, Integer )
		  Assert.IsTrue keys.IndexOf( "field1" ) <> -1
		  
		  dim values() as string = r.HValues( "xut:hash" )
		  Assert.AreEqual 1, CType( values.Ubound, Integer )
		  Assert.IsTrue values.IndexOf( "newvalue" ) <> -1
		  
		  Assert.IsTrue r.HExists( "xut:hash", "field1" )
		  Assert.IsFalse r.HExists( "xut:hash", "field1000" )
		  Assert.IsFalse r.HExists( "xut:something", "f" )
		  
		  Assert.AreEqual 2, r.HLen( "xut:hash" )
		  
		  d = r.HScan( "xut:hash" )
		  Assert.AreEqual 2, d.Count
		  Assert.IsTrue d.HasKey( "field1" )
		  Assert.AreEqual "newvalue", d.Value( "field1" ).StringValue
		  
		  Assert.AreEqual 2, r.HDelete( "xut:hash", "field1", "field2", "field3" )
		  
		  r.HSetMultiple "xut:hash", d
		  d = r.HGetAll( "xut:hash" )
		  Assert.AreEqual 2, d.Count
		  Assert.IsTrue d.HasKey( "field1" )
		  Assert.AreEqual "newvalue", d.Value( "field1" ).StringValue
		  
		  dim varr() as variant = r.HGetMultiple( "xut:hash", "field1", "field1000", "field2" )
		  Assert.AreEqual 2, CType( varr.Ubound, Integer )
		  Assert.AreEqual "newvalue", varr( 0 ).StringValue
		  Assert.IsNil varr( 1 )
		  
		  call r.Delete( r.Scan( "xut:*" ) )
		  
		  Assert.AreEqual 1, r.HIncrementBy( "xut:hash", "field1", 1 )
		  Assert.AreEqual 11, r.HIncrementBy( "xut:hash", "field1", 10 )
		  
		  Assert.AreEqual 1.0, r.HIncrementByFloat( "xut:hash", "field2", 1.0 )
		  Assert.AreEqual -1.0, r.HIncrementByFloat( "xut:hash", "field2", -2.0 )
		  
		  call r.Delete( r.Scan( "xut:*" ) )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IncrementByFloatTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual 0.5, r.IncrementByFloat( "xut:key", 0.5 )
		  Assert.AreEqual 1.0, r.IncrementByFloat( "xut:key", 0.5 )
		  
		  Assert.IsTrue r.Set( "xut:key", "1.75", 10 )
		  Assert.AreEqual 4.25, r.IncrementByFloat( "xut:key", 2.5 )
		  
		  Assert.AreEqual 4.0, r.IncrementByFloat( "xut:key", -0.25 )
		  
		  r.Delete "xut:key"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IncrementByTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual 2, r.IncrementBy( "xut:key", 2 )
		  Assert.AreEqual 5, r.IncrementBy( "xut:key", 3 )
		  
		  Assert.IsTrue r.Set( "xut:key", "4", 10 )
		  Assert.AreEqual 10, r.IncrementBy( "xut:key", 6 )
		  
		  r.Delete "xut:key"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IncrementTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual 1, r.Increment( "xut:key" )
		  Assert.AreEqual 2, r.Increment( "xut:key" )
		  
		  Assert.IsTrue r.Set( "xut:key", "4", 10 )
		  Assert.AreEqual 5, r.Increment( "xut:key" )
		  
		  r.Delete "xut:key"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub InfoTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  dim memory as Dictionary = r.Info( Redis_MTC.kSectionMemory )
		  Assert.IsTrue memory.Count <> 0
		  Assert.IsTrue memory.HasKey( "used_memory" )
		  Assert.IsTrue memory.Value( "used_memory" ).Type = Variant.TypeString
		  
		  dim all as Dictionary = r.Info
		  Assert.IsTrue all.HasKey( "server" )
		  Assert.IsTrue all.HasKey( "memory" )
		  Assert.IsTrue all.Value( "memory" ) isa Dictionary
		  
		  dim server as Dictionary = all.Value( "server" )
		  Assert.IsTrue server.Count <> 0
		  Assert.IsTrue server.HasKey( "redis_version" )
		  Assert.IsTrue server.Value( "redis_version" ).Type = Variant.TypeString
		  Assert.IsTrue server.Value( "redis_version" ).StringValue <> ""
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub KeysTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  dim keys() as string = r.Keys( "xut:*" )
		  Assert.AreEqual CType( -1, Int32 ), keys.Ubound
		  
		  Assert.IsTrue r.Set( "xut:key", "value" )
		  Assert.IsTrue r.Set( "xut:key2", "another" )
		  
		  keys = r.Keys( "xut:*" )
		  Assert.AreEqual CType( 1, Int32 ), keys.Ubound
		  
		  keys = r.Keys( "xut:*2" )
		  Assert.AreEqual CType( 0, Int32 ), keys.Ubound
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LastCommandTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  dim eol as string = EndOfLine.Windows
		  
		  Assert.IsTrue r.Set( "xut:key", "xxx" )
		  dim expected as string = "*3" + eol + "$3" + eol + "SET" + eol + "$7" + eol + "xut:key" + eol + "$3" + eol + "xxx"
		  Assert.AreSame expected, r.LastCommand
		  
		  dim msg as string = "hi"
		  dim cmd as string = "ECHO " + msg
		  Assert.AreSame msg, r.Execute( cmd )
		  Assert.AreSame cmd, r.LastCommand
		  
		  r.Delete "xut:key"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ListFunctionsTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  //
		  // LPush
		  // LPushX
		  //
		  Assert.AreEqual 2, r.LPush( "xut:list1", "value1", "value2" )
		  Assert.AreEqual 3, r.LPushX( "xut:list1", "value3" )
		  Assert.AreEqual 0, r.LPushX( "xut:listxxx", "value3" )
		  
		  //
		  // RPush
		  // RPushX
		  //
		  Assert.AreEqual 5, r.RPush( "xut:list1", "value4", "value5" )
		  Assert.AreEqual 6, r.RPushX( "xut:list1", "value6" )
		  Assert.AreEqual 0, r.RPushX( "xut:listxxx", "value3" )
		  
		  //
		  // LLen
		  //
		  Assert.AreEqual 6, r.LLen( "xut:list1" )
		  
		  //
		  // LRange
		  //
		  if true then
		    dim arr() as string = r.LRange( "xut:list1", 0, -1 )
		    Assert.AreEqual CType( 5, Int32 ), arr.Ubound
		    
		    arr = r.LRange( "xut:list1", 0, 1 )
		    Assert.AreEqual CType( 1, Int32 ), arr.Ubound
		  end if
		  
		  //
		  // LIndex
		  //
		  Assert.AreEqual "value6", r.LIndex( "xut:list1", -1 )
		  
		  //
		  // LTrim
		  //
		  r.LTrim "xut:list1", 0, 4
		  Assert.AreEqual 5, r.LLen( "xut:list1" )
		  
		  //
		  // LPop
		  // RPop
		  //
		  Assert.AreEqual "value3", r.LPop( "xut:list1" )
		  Assert.AreEqual "value5", r.RPop( "xut:list1" )
		  
		  //
		  // LSet
		  //
		  r.LSet( "xut:list1", 1, "newvalue2" )
		  Assert.AreEqual "newvalue2", r.LIndex( "xut:list1", 1 )
		  
		  #pragma BreakOnExceptions false
		  try
		    r.LSet( "xut:list1", 10, "outofrange" )
		    Assert.Fail "No out of range error"
		  catch err as OutOfBoundsException
		    Assert.Pass
		  end try
		  #pragma BreakOnExceptions default 
		  
		  //
		  // LInsertBefore
		  // LInsertAfter
		  //
		  r.Delete "xut:list1"
		  Assert.AreEqual 3, r.RPush( "xut:list1", "1", "2", "3" )
		  
		  Assert.AreEqual 4, r.LInsertBefore( "xut:list1", "2", "before" )
		  Assert.AreEqual "before", r.LIndex( "xut:list1", 1 )
		  
		  Assert.AreEqual 5, r.LInsertAfter( "xut:list1", "2", "after" )
		  Assert.AreEqual "after", r.LIndex( "xut:list1", 3 )
		  
		  //
		  // LRem
		  //
		  r.Delete "xut:list1"
		  Assert.AreEqual 7, r.RPush( "xut:list1", "1", "2", "3", "1", "1", "1", "1" )
		  
		  Assert.AreEqual 4, r.LRem( "xut:list1", -4, "1" ), "LRem"
		  Assert.AreEqual "1", r.LIndex( "xut:list1", 0 ), "LRem - index 0"
		  Assert.AreEqual "3", r.LIndex( "xut:list1", -1 ), "LRem - index -1"
		  
		  //
		  // RPopLPush
		  //
		  Assert.AreEqual "3", r.RPopLPush( "xut:list1", "xut:list2" )
		  
		  //
		  // LPopBlocking
		  // RPopBlocking
		  // RPopLPushBlocking
		  //
		  call r.Delete "xut:list1", "xut:list2"
		  Assert.AreEqual 3, r.RPush( "xut:list2", "1", "2", "3" )
		  
		  if true then
		    dim arr() as string
		    
		    call r.Delete "xut:list1", "xut:list2"
		    Assert.AreEqual 3, r.RPush( "xut:list2", "1", "2", "3" )
		    
		    arr = r.LPopBlocking( 1, "xut:list1", "xut:list2" )
		    Assert.AreEqual CType( 1, Int32 ), arr.Ubound, "LPopBlocking"
		    Assert.AreEqual "xut:list2", arr( 0 )
		    Assert.AreEqual "1", arr( 1 )
		    
		    call r.Delete "xut:list1", "xut:list2"
		    Assert.AreEqual 3, r.RPush( "xut:list2", "1", "2", "3" )
		    
		    arr = r.LPopBlocking( 1, array( "xut:list1", "xut:list2" ) ) 
		    Assert.AreEqual CType( 1, Int32 ), arr.Ubound, "LPopBlocking with array"
		    Assert.AreEqual "xut:list2", arr( 0 )
		    Assert.AreEqual "1", arr( 1 )
		    
		    call r.Delete "xut:list1", "xut:list2"
		    Assert.AreEqual 3, r.RPush( "xut:list2", "1", "2", "3" )
		    
		    arr = r.RPopBlocking( 1, "xut:list1", "xut:list2" )
		    Assert.AreEqual CType( 1, Int32 ), arr.Ubound, "RPopBlocking"
		    Assert.AreEqual "xut:list2", arr( 0 )
		    Assert.AreEqual "3", arr( 1 )
		    
		    call r.Delete "xut:list1", "xut:list2"
		    Assert.AreEqual 3, r.RPush( "xut:list2", "1", "2", "3" )
		    
		    arr = r.RPopBlocking( 1, array( "xut:list1", "xut:list2" ) )
		    Assert.AreEqual CType( 1, Int32 ), arr.Ubound, "RPopBlocking with array"
		    Assert.AreEqual "xut:list2", arr( 0 )
		    Assert.AreEqual "3", arr( 1 )
		    
		    call r.Delete "xut:list1", "xut:list2"
		    
		    dim oldTimeout as integer = r.TimeoutSecs
		    
		    r.TimeoutSecs = 1
		    #pragma BreakOnExceptions false
		    try
		      arr = r.LPopBlocking( 2, "xut:doesn'texist" )
		      Assert.Fail "Should have timed out"
		    catch err as KeyNotFoundException
		      Assert.Pass
		    end try
		    #pragma BreakOnExceptions default 
		    Assert.AreEqual 1, r.TimeoutSecs
		    r.TimeoutSecs = oldTimeout
		    
		    Assert.AreEqual 3, r.RPush( "xut:list1", "1", "2", "3" )
		    Assert.AreEqual "3", r.RPopLPushBlocking( 1, "xut:list1", "xut:list2" )
		    Assert.AreEqual "3", r.LIndex( "xut:list2", 0 )
		  end if
		  
		  call r.Delete "xut:list1", "xut:list2"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MoveTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key", "value", 30 )
		  Assert.AreEqual 1, r.Move( "xut:key", 1 ), "Couldn't move"
		  r.SelectDB 1
		  Assert.AreEqual "value", r.Get( "xut:key" )
		  r.Delete "xut:key"
		  r.SelectDB 0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ObjectEncodingTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key", "value", 30 )
		  dim enc as string = r.ObjectEncoding( "xut:key" )
		  Assert.AreEqual "embstr", enc
		  
		  #pragma BreakOnExceptions false
		  try
		    call r.ObjectEncoding( "xut:key3" )
		    Assert.Fail "Key should not exist"
		  catch err as KeyNotFoundException
		    Assert.Pass "Key doesn't exist"
		  end try
		  #pragma BreakOnExceptions default
		  
		  
		  r.Delete( "xut:key" )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Pause(milliseconds As Integer)
		  dim targetMicroseconds as double = Microseconds + ( milliseconds * 1000.0 )
		  
		  while Microseconds < targetMicroseconds
		    App.YieldToNextThread
		  wend
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PersistTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key1", "v", 30 )
		  Assert.IsTrue r.TimeToLiveMs( "xut:key1" ) <> -1
		  r.Persist( "xut:key1" )
		  Assert.AreEqual -1, r.TimeToLiveMs( "xut:key1" )
		  r.Delete "xut:key1"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PingTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreSame "PONG", r.Ping
		  Assert.AreSame "something", r.Ping( "something" )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PipelineTest()
		  const kUB as Int32 = 999
		  
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  r.StartPipeline 7
		  
		  for i as integer = 0 to kUB
		    Assert.IsTrue r.Set( "xut:key" + str( i ), "xxx" )
		  next
		  
		  dim arr() as variant = r.FlushPipeline( false )
		  Assert.AreEqual kUB, arr.Ubound
		  
		  for i as integer = 0 to kUB
		    dim v as variant = arr( i )
		    Assert.AreEqual Variant.TypeBoolean, v.Type, "Wasn't boolean"
		    Assert.IsTrue v.BooleanValue
		    Assert.AreSame "xxx", r.Get( "xut:key" + str( i ) ), i.ToText
		  next
		  
		  r.StartPipeline 13
		  
		  for i as integer = 0 to kUB step 4
		    dim keys() as string
		    for x as integer = 0 to 3
		      keys.Append "xut:key" + str( i + x )
		    next
		    call r.GetMultiple( keys )
		  next
		  
		  arr = r.FlushPipeline( false )
		  
		  Assert.AreEqual CType( ( kUB ) / 4, Int32 ), arr.Ubound
		  
		  for i as integer = 0 to arr.Ubound
		    dim v as variant = arr( i )
		    Assert.IsTrue v.IsArray, "IsArray"
		    dim subArr() as variant = v
		    Assert.AreEqual CType( 3, Int32 ), subArr.Ubound
		    for x as integer = 0 to subArr.Ubound
		      Assert.AreEqual "xxx", subArr( x ).StringValue, subArr( x ).StringValue.ToText
		    next
		  next
		  
		  call r.Delete( r.Scan( "xut:*" ) )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RandomKeyTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key", "value" )
		  dim randKey as string = r.RandomKey
		  Assert.Message "Key is " + randKey.ToText
		  Assert.IsTrue randKey <> ""
		  r.Delete "xut:key"
		  
		  if r.DBSize <> 0 then
		    Assert.Message "Could not test for KeyNotFoundException"
		  else
		    #pragma BreakOnExceptions false
		    try
		      call r.RandomKey
		      Assert.Fail "Should have raised KeyNotFoundException"
		    catch err as KeyNotFoundException
		      Assert.Pass
		    end try
		    #pragma BreakOnExceptions default
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RedisControlTest()
		  dim r as new RedisControl_MTC
		  Assert.IsFalse r.IsConnected
		  
		  r.Address = App.RedisAddress
		  r.Port = App.RedisPort
		  Assert.IsTrue r.Connect( App.RedisPassword )
		  
		  Assert.IsTrue r.Set( "xut:key", "value", 1000 )
		  
		  r = new RedisControl_MTC
		  r.Address = ""
		  Assert.IsFalse r.Connect
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Redis_ResponseInPipeline(sender As Redis_MTC)
		  const kExpected = 100000
		  
		  if sender.ResultCount = kExpected then
		    AsyncComplete
		    dim results() as variant = sender.ReadPipeline
		    Assert.AreEqual kExpected - 1, CType( results.Ubound, integer )
		    
		    RemoveHandler sender.ResponseInPipeline, WeakAddressOf Redis_ResponseInPipeline
		  else
		    Assert.Message "Insufficient results, waiting"
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RenameTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key", "value" )
		  r.Rename "xut:key", "xut:key1"
		  Assert.AreSame "value", r.Get( "xut:key1" )
		  
		  call r.Delete( r.Scan( "xut:*" ) )
		  
		  Assert.IsTrue r.Set( "xut:key1", "value" )
		  r.Rename "xut:key1", "xut:key2", true
		  Assert.Pass "Rename to non-existent key passed"
		  
		  Assert.IsTrue r.Set( "xut:key1", "first" )
		  #pragma BreakOnExceptions false
		  try
		    r.Rename "xut:key1", "xut:key2", true
		    Assert.Fail "Renamed to existing key"
		  catch err as RuntimeException
		    Assert.Pass "Could not rename to existing key"
		  end try
		  #pragma BreakOnExceptions default
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ResponseInPipelineEventTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  Redis = r
		  AddHandler r.ResponseInPipeline, WeakAddressOf Redis_ResponseInPipeline
		  
		  r.StartPipeline( 11 )
		  for i as integer = 0 to 99999
		    Assert.IsTrue r.Set( "xut:key", "xxx" )
		  next
		  
		  AsyncAwait 2
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ScanTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  r.SetMultiple "xut:key1" : "value", "xut:key2" : "other", "xutut:key" : "value"
		  dim keys() as string = r.Scan( "xut:*" )
		  Assert.AreEqual CType( 1, Int32 ), keys.Ubound
		  call r.Delete( keys )
		  call r.Delete( "xutut:key" )
		  
		  const kUB as Int32 = 999
		  
		  dim arr() as pair
		  
		  for i as integer = 0 to kUB
		    arr.Append new Pair( "xut:key" + str( i ), "value" )
		    arr.Append new Pair( "xut:nokey" + str( i ), "no value" )
		  next
		  
		  r.SetMultiple arr
		  
		  keys = r.Scan( "xut:key*" )
		  Assert.AreEqual kUB, keys.Ubound
		  
		  for i as integer = 0 to kUB
		    Assert.IsTrue keys.IndexOf( "xut:key" + str( i ) ) <> -1
		  next
		  
		  keys = r.Scan( "xut:*" )
		  Assert.AreEqual CType( kUB * 2 + 1, Int32 ), keys.Ubound
		  
		  for i as integer = 0 to kUB
		    Assert.IsTrue keys.IndexOf( "xut:key" + str( i ) ) <> -1
		    Assert.IsTrue keys.IndexOf( "xut:nokey" + str( i ) ) <> -1
		  next
		  
		  call r.Delete( keys )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SelectDBTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:db0", "0", 30000 )
		  r.SelectDB 1
		  Assert.IsTrue r.Set( "xut:db1", "1", 30000 )
		  
		  dim keys() as string = r.Scan( "xut:*" )
		  Assert.AreEqual CType( 0, Int32 ), keys.Ubound, "DB 1"
		  Assert.AreEqual "xut:db1", keys( 0 )
		  r.Delete "xut:db1"
		  
		  r.SelectDB 0
		  keys = r.Scan( "xut:*" )
		  Assert.AreEqual CType( 0, Int32 ), keys.Ubound, "DB 0"
		  Assert.AreEqual "xut:db0", keys( 0 )
		  r.Delete "xut:db0"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetBitGetBitTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual 0, r.SetBit( "xut:key", 0, 1 )
		  Assert.AreEqual 1, r.GetBit( "xut:key", 0 )
		  
		  Assert.AreEqual 1, r.SetBit( "xut:key", 0, 0 )
		  Assert.AreEqual 0, r.GetBit( "xut:key", 0 )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetExpiredTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key", "value", 10 )
		  Pause 20
		  
		  #pragma BreakOnExceptions false
		  try
		    call r.Get( "xut:key" )
		    Assert.Fail "Fetched expired key"
		  catch err as KeyNotFoundException
		    Assert.Pass "Properly set expiring key"
		  end try
		  #pragma BreakOnExceptions default
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetFunctionsTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual 6, r.SAdd( "xut:set", "1", "2", "3", "4", "5", "6" )
		  Assert.AreEqual 2, r.SRemove( "xut:set", "5", "6", "7" )
		  
		  dim members() as string = r.SScan( "xut:set" )
		  Assert.AreEqual 3, CType( members.Ubound, Integer )
		  
		  Assert.IsTrue r.SIsMember( "xut:set", "1" )
		  Assert.IsFalse r.SIsMember( "xut:set", "10" )
		  Assert.IsFalse r.SIsMember( "xut:setxxx", "1" )
		  
		  members = r.SMembers( "xut:set" )
		  Assert.AreEqual 3, CType( members.Ubound, Integer )
		  
		  dim m as string = r.SRandomMember( "xut:set" )
		  Assert.IsTrue members.IndexOf( m ) <> -1
		  
		  for i as integer = 0 to members.Ubound
		    m = r.SPop( "xut:set" )
		    Assert.IsTrue members.IndexOf( m ) <> -1
		  next
		  
		  Assert.AreEqual members.Ubound + 1, r.SAdd( "xut:set", members ), "Add members before pop"
		  dim popped() as string = r.SPop( "xut:set", 2 )
		  Assert.AreEqual 1, CType( popped.Ubound, Integer )
		  
		  call r.Delete( r.Scan( "xut:*" ) )
		  
		  Assert.AreEqual members.Ubound + 1, r.SAdd( "xut:set", members )
		  Assert.IsTrue r.SMove( "xut:set", "xut:setdest", "1" )
		  Assert.IsFalse r.SMove( "xut:set", "xut:setdest", "100" )
		  Assert.IsFalse r.SMove( "xut:setxxx", "xut:setdest", "1" )
		  
		  Assert.AreEqual "1", r.SPop( "xut:setdest" )
		  
		  call r.SAdd( "xut:set", members )
		  Assert.AreEqual members.Ubound + 1, r.SCard( "xut:set" ), "Add members before diff"
		  
		  if true then
		    dim diff() as string
		    diff = r.SDifference( "xut:set" )
		    Assert.AreEqual members.Ubound, diff.Ubound, "SDifference with single key"
		    diff = r.SDifference( "xut:setxxx" )
		    Assert.AreEqual -1, CType( diff.Ubound, integer ), "SDifference with unknown key"
		  end if
		  
		  if true then
		    dim inter() as string
		    inter = r.SIntersection( "xut:set" )
		    Assert.AreEqual members.Ubound, inter.Ubound 
		    inter = r.SIntersection( "xut:setxxx" )
		    Assert.AreEqual -1, CType( inter.Ubound, integer )
		  end if
		  
		  if true then
		    dim union() as string
		    union = r.SUnion( "xut:set" )
		    Assert.AreEqual members.Ubound, union.Ubound 
		    union = r.SUnion( "xut:setxxx" )
		    Assert.AreEqual -1, CType( union.Ubound, integer )
		  end if
		  
		  call r.Delete( r.Scan( "xut:*" ) )
		  call r.SAdd( "xut:set", array( "1", "2", "3" ) )
		  call r.SAdd( "xut:set1", "3", "4", "5" )
		  
		  if true then
		    dim diff() as string
		    diff = r.SDifference( "xut:set", "xut:set1" )
		    Assert.AreEqual 1, CType( diff.Ubound, integer )
		  end if
		  
		  if true then
		    dim inter() as string
		    inter = r.SIntersection( "xut:set", "xut:set1" )
		    Assert.AreEqual 0, CType( inter.Ubound, integer )
		    Assert.AreEqual "3", inter( 0 )
		  end if
		  
		  if true then
		    dim union() as string
		    union = r.SUnion( "xut:set", "xut:set1" )
		    Assert.AreEqual 4, CType( union.Ubound, integer )
		  end if
		  
		  if true then
		    dim diff() as string
		    Assert.AreEqual 2, r.SDifferenceTo( "xut:dest", "xut:set", "xut:set1" )
		    diff = r.SMembers( "xut:dest" )
		    Assert.AreEqual 1, CType( diff.Ubound, integer )
		    r.Delete "xut:dest"
		  end if
		  
		  if true then
		    dim inter() as string
		    Assert.AreEqual 1, r.SIntersectionTo( "xut:dest", "xut:set", "xut:set1" )
		    inter = r.SMembers( "xut:dest" )
		    Assert.AreEqual 0, CType( inter.Ubound, integer )
		    r.Delete "xut:dest"
		  end if
		  
		  if true then
		    dim union() as string
		    Assert.AreEqual 5, r.SUnionTo( "xut:dest", "xut:set", "xut:set1" )
		    union = r.SMembers( "xut:dest" )
		    Assert.AreEqual 4, CType( union.Ubound, integer )
		    r.Delete "xut:dest"
		  end if
		  
		  call r.Delete( r.Scan( "xut:*" ) )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetGetMultipleTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  r.SetMultiple "xut:key1" : "value1", "xut:key2" : "value2"
		  dim arr() as variant = r.GetMultiple( "xut:key1", "xut:key2", "xut:key3" )
		  Assert.AreEqual CType( 2, Int32 ), arr.Ubound
		  Assert.AreSame "value1", arr( 0 ).StringValue
		  Assert.AreSame "value2", arr( 1 ).StringValue
		  Assert.IsTrue arr( 2 ).IsNull
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetGetTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key", "value" )
		  Assert.AreSame "value", r.Get( "xut:key" )
		  r.Delete "xut:key"
		  
		  Assert.IsTrue r.Set( "xut:©", "™" )
		  Assert.AreSame "™", r.Get( "xut:©" )
		  r.Delete "xut:©"
		  
		  Assert.IsTrue r.Set( "xut:key", "value", 0, Redis_MTC.SetMode.IfNotExists )
		  Assert.IsFalse r.Set( "xut:key", "other", 0, Redis_MTC.SetMode.IfNotExists )
		  Assert.IsTrue r.Set( "xut:key", "other", 0, Redis_MTC.SetMode.IfExists )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetMultipleIfNoneExistTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.SetMultipleIfNoneExist( "xut:key1" : "value", "xut:key2" : "another" ), "Initial set"
		  Assert.IsFalse r.SetMultipleIfNoneExist( "xut:key2" : "value", "xut:key3" : "another" ), "One exists"
		  call r.Delete( "xut:key1", "xut:key2" )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetRangeTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual 2, r.SetRange( "xut:key", 0, "hi" )
		  Assert.AreSame "hi", r.Get( "xut:key" )
		  
		  Assert.AreEqual 8, r.SetRange( "xut:key", 2, " there" )
		  Assert.AreSame "hi there", r.Get( "xut:key" )
		  
		  Assert.AreEqual 8, r.SetRange( "xut:key", 1, "o" )
		  Assert.AreSame "ho there", r.Get( "xut:key" )
		  
		  r.Delete "xut:key"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SortTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual 5, r.RPush( "xut:mylist", "2", "20", "100", "10", "1" )
		  
		  dim arr() as string
		  
		  arr = r.Sort( "xut:mylist" )
		  Assert.AreEqual 4, CType( arr.Ubound, Integer )
		  Assert.AreEqual "1", arr( 0 )
		  Assert.AreEqual "100", arr( 4 )
		  
		  arr = r.Sort( "xut:mylist", false, true )
		  Assert.AreEqual 4, CType( arr.Ubound, Integer )
		  Assert.AreEqual "20", arr( 0 )
		  Assert.AreEqual "1", arr( 4 )
		  
		  arr = r.Sort( "xut:mylist", true, false, 0, 3 )
		  Assert.AreEqual 2, CType( arr.Ubound, Integer )
		  Assert.AreEqual "1", arr( 0 )
		  Assert.AreEqual "10", arr( 2 )
		  
		  arr() = r.Sort( "xut:mylist", true, false, 0, -1 )
		  Assert.AreEqual 4, CType( arr.Ubound, Integer ), "Negative count"
		  
		  r.SetMultiple "xut:by_1" : "100", "xut:by_2" : "20", "xut:by_10" : "10", "xut:by_20" : "2", "xut:by_100" : "1"
		  arr() = r.Sort( "xut:mylist", true, false, 0, -1, "xut:by_*" )
		  Assert.AreEqual 4, CType( arr.Ubound, Integer )
		  Assert.AreEqual "100", arr( 0 )
		  Assert.AreEqual "1", arr( 4 )
		  
		  r.SetMultiple "xut:object_1" : "a", "xut:object_2" : "b", "xut:object_10" : "c", "xut:object_20" : "d", "xut:object_100" : "e"
		  arr() = r.Sort( "xut:mylist", true, false, 0, -1, "xut:by_*", array( "xut:object_*" ) )
		  Assert.AreEqual 4, CType( arr.Ubound, Integer )
		  Assert.AreEqual "e", arr( 0 )
		  Assert.AreEqual "a", arr( 4 )
		  
		  call r.Delete( r.Scan( "xut:*" ) )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SortToTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual 5, r.RPush( "xut:mylist", "2", "20", "100", "10", "1" )
		  
		  dim arr() as string
		  
		  Assert.AreEqual 5, r.SortTo( "xut:dest", "xut:mylist" )
		  arr = r.LRange( "xut:dest", 0, -1 )
		  Assert.AreEqual 4, CType( arr.Ubound, Integer )
		  Assert.AreEqual "1", arr( 0 )
		  Assert.AreEqual "100", arr( 4 )
		  
		  Assert.AreEqual 5, r.SortTo( "xut:dest", "xut:mylist", false, true )
		  arr = r.LRange( "xut:dest", 0, -1 )
		  Assert.AreEqual 4, CType( arr.Ubound, Integer )
		  Assert.AreEqual "20", arr( 0 )
		  Assert.AreEqual "1", arr( 4 )
		  
		  Assert.AreEqual 3, r.SortTo( "xut:dest", "xut:mylist", true, false, 0, 3 )
		  arr = r.LRange( "xut:dest", 0, -1 )
		  Assert.AreEqual 2, CType( arr.Ubound, Integer )
		  Assert.AreEqual "1", arr( 0 )
		  Assert.AreEqual "10", arr( 2 )
		  
		  Assert.AreEqual 5, r.SortTo( "xut:dest", "xut:mylist", true, false, 0, -1 )
		  arr = r.LRange( "xut:dest", 0, -1 )
		  Assert.AreEqual 4, CType( arr.Ubound, Integer ), "Negative count"
		  
		  r.SetMultiple "xut:by_1" : "100", "xut:by_2" : "20", "xut:by_10" : "10", "xut:by_20" : "2", "xut:by_100" : "1"
		  Assert.AreEqual 5, r.SortTo( "xut:dest", "xut:mylist", true, false, 0, -1, "xut:by_*" )
		  arr = r.LRange( "xut:dest", 0, -1 )
		  Assert.AreEqual 4, CType( arr.Ubound, Integer )
		  Assert.AreEqual "100", arr( 0 )
		  Assert.AreEqual "1", arr( 4 )
		  
		  r.SetMultiple "xut:object_1" : "a", "xut:object_2" : "b", "xut:object_10" : "c", "xut:object_20" : "d", "xut:object_100" : "e"
		  Assert.AreEqual 5, r.SortTo( "xut:dest", "xut:mylist", true, false, 0, -1, "xut:by_*", array( "xut:object_*" ) )
		  arr = r.LRange( "xut:dest", 0, -1 )
		  Assert.AreEqual 4, CType( arr.Ubound, Integer )
		  Assert.AreEqual "e", arr( 0 )
		  Assert.AreEqual "a", arr( 4 )
		  
		  call r.Delete( r.Scan( "xut:*" ) )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StrLenTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.AreEqual 0, r.StrLen( "xut:key" )
		  Assert.IsTrue r.Set( "xut:key", "hi" )
		  Assert.AreEqual 2, r.StrLen( "xut:key" )
		  
		  r.Delete "xut:key"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ThreadTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  Redis = r
		  
		  call r.Set( "xut:mainthreadtest", "xxx" )
		  
		  dim t as new Thread
		  AddHandler t.Run, WeakAddressOf ThreadTestRun
		  t.Run
		  while t.State = Thread.NotRunning
		    App.YieldToNextThread
		  wend
		  
		  while t.State <> Thread.NotRunning
		    Assert.IsTrue r.Set( "xut:threadtestkey", "main" )
		    Assert.AreEqual "xxx", r.GetSet( "xut:mainthreadtest", "xxx" )
		  wend
		  
		  RemoveHandler t.Run, WeakAddressOf ThreadTestRun
		  
		  call r.Delete( "xut:threadtestkey", "xut:mainthreadtest" )
		  
		  Redis = nil
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ThreadTestRun(sender As Thread)
		  #pragma unused sender
		  
		  dim r as Redis_MTC = Redis
		  
		  dim targetMs as double = Microseconds + 500000
		  while Microseconds <= targetMs
		    Assert.IsTrue r.Set( "xut:threadtestkey", "value" ), "Thread"
		  wend
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TimeTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  dim d as Date = r.Time
		  dim now as new Date
		  Assert.IsTrue abs( now.TotalSeconds -  d.TotalSeconds ) <= 1.0, "Server time more than a second different"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TimeToLiveTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key1", "value", 60 )
		  Assert.IsTrue r.TimeToLiveMs( "xut:key1" ) >= 58
		  r.Delete "xut:key1"
		  
		  #pragma BreakOnExceptions false
		  try
		    call r.TimeToLiveMs( "xut:key1" )
		    Assert.Fail "Key should not exist"
		  catch err as KeyNotFoundException
		    Assert.Pass "Unknown key"
		  end try
		  #pragma BreakOnExceptions default
		  
		  Assert.IsTrue r.Set( "xut:key1", "value" )
		  Assert.AreEqual -1, r.TimeToLiveMs( "xut:key1" )
		  
		  r.Delete "xut:key1"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TouchAndObjectIdleTimeTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key1", "value", 30 )
		  Assert.IsTrue r.Set( "xut:key2", "another", 30 )
		  
		  Assert.AreEqual 0, r.ObjectIdleTime( "xut:key1" )
		  Pause 3
		  
		  Assert.AreEqual 2, r.Touch( "xut:key1", "xut:key2", "xut:key3" )
		  
		  Assert.IsTrue r.ObjectIdleTime( "xut:key1" ) < 2
		  
		  #pragma BreakOnExceptions false
		  try
		    call r.ObjectIdleTime( "xut:key3" )
		    Assert.Fail "Key should not exist"
		  catch err as KeyNotFoundException
		    Assert.Pass "Key doesn't exist"
		  end try
		  #pragma BreakOnExceptions default
		  
		  call r.Delete( "xut:key1", "xut:key2" )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TypeTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  Assert.IsTrue r.Set( "xut:key1", "value" )
		  Assert.AreEqual "string", r.Type( "xut:key1" )
		  r.Delete "xut:key1"
		  
		  #pragma BreakOnExceptions false
		  try
		    call r.Type( "xut:key1" )
		    Assert.Fail "Did not raise exception"
		  catch err as KeyNotFoundException
		    Assert.Pass "Raised exception"
		  end try
		  #pragma BreakOnExceptions default
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Redis As Redis_MTC
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Duration"
			Group="Behavior"
			Type="Double"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FailedTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IncludeGroup"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsRunning"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="NotImplementedCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="PassedTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RunTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SkippedTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StopTestOnFail"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
