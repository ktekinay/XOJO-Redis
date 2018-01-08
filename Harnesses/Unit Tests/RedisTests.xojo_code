#tag Class
Protected Class RedisTests
Inherits TestGroup
	#tag Event
		Sub Setup()
		  self.Redis = nil
		  
		  dim r as Redis_MTC
		  
		  #pragma BreakOnExceptions false
		  try
		    r = new Redis_MTC
		  catch err as RuntimeException
		    r = new Redis_MTC( "pw" )
		    r.ConfigSet Redis_MTC.kConfigRequirePass, ""
		    r = new Redis_MTC
		  end try
		  #pragma BreakOnExceptions default
		  
		  call r.Delete( r.Scan( "xut:*" ) )
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AppendTest()
		  dim r as new Redis_MTC
		  
		  Assert.AreEqual 1, r.Append( "xut:key", "h" )
		  Assert.AreSame "h", r.Get( "xut:key" )
		  
		  Assert.AreEqual 2, r.Append( "xut:key", "i" )
		  Assert.AreSame "hi", r.Get( "xut:key" )
		  
		  r.Delete "xut:key"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AuthTest()
		  dim r as new Redis_MTC
		  r.ConfigSet Redis_MTC.kConfigRequirePass, "pw"
		  
		  r = nil
		  
		  #pragma BreakOnExceptions false
		  try
		    r = new Redis_MTC
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
		Sub BitCountTest()
		  dim r as new Redis_MTC
		  
		  Assert.IsTrue r.Set( "xut:key", "abc123", 100 )
		  Assert.AreEqual 20, r.BitCount( "xut:key" ), "Full"
		  Assert.AreEqual 6, r.BitCount( "xut:key", 0, 1 ), "Partial"
		  
		  r.Delete "xut:key"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BitFieldIncrementByTest()
		  dim r as new Redis_MTC
		  
		  Assert.AreEqual 0, r.BitFieldSet( "xut:key", r.kTypeUInt32, 0, 0 )
		  Assert.AreEqual Int64( 5 ), r.BitFieldIncrementBy( "xut:key", "u8", 0, 5 )
		  Assert.AreEqual Int64( 7 ), r.BitFieldIncrementBy( "xut:key", "u8", 0, 2, false, Redis_MTC.Overflows.Sat )
		  Assert.Message "With Overflow: " + &uA + ReplaceLineEndings( r.LastCommand.Trim, &uA ).ToText
		  
		  r.Delete "xut:key"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BitFieldSetGetTest()
		  dim r as new Redis_MTC
		  
		  Assert.AreEqual 0, r.BitFieldSet( "xut:key","u8", 0, &b10101010 ), "Set 1"
		  Assert.AreEqual CType( &b0101, Int64 ), r.BitFieldSet( "xut:key", "u4", 1, 1 ), "Set 2"
		  Assert.AreEqual CType( &b10001010, Int64 ), r.BitFieldGet( "xut:key", r.kTypeUInt8, 0 ), "Get"
		  
		  r.Delete "xut:key"
		  
		  Assert.AreEqual 0, r.BitFieldSet( "xut:key", "u32", 0, &hFFFFFFFF )
		  Assert.AreEqual CType( &hFF, Int64 ), r.BitFieldSet( "xut:key", "u8", 1, 0, true )
		  Assert.AreEqual CType( &hFF00FFFF, Int64 ), r.BitFieldGet( "xut:key", "u32", 0 )
		  Assert.AreEqual CType( &hFFFF, Int64 ), r.BitfieldGet( "xut:key", "u16", 1, true )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BitOpTest()
		  dim r as new Redis_MTC
		  
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
		  dim r as new Redis_MTC
		  
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
		Sub ConfigGetTest()
		  dim r as new Redis_MTC
		  
		  dim values as Dictionary = r.ConfigGet
		  Assert.IsNotNil values
		  
		  values = r.ConfigGet( "requirepas*" )
		  Assert.AreEqual 1, values.Count
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ConnectTest()
		  dim r as new Redis_MTC
		  #pragma unused r
		  
		  Assert.Pass "Connected"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DecrementByTest()
		  dim r as new Redis_MTC
		  
		  Assert.AreEqual -2, r.DecrementBy( "xut:key", 2 )
		  Assert.AreEqual -5, r.DecrementBy( "xut:key", 3 )
		  
		  Assert.IsTrue r.Set( "xut:key", "4", 10 )
		  Assert.AreEqual 1, r.DecrementBy( "xut:key", 3 )
		  
		  r.Delete "xut:key"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DecrementTest()
		  dim r as new Redis_MTC
		  
		  Assert.AreEqual -1, r.Decrement( "xut:key" )
		  Assert.AreEqual -2, r.Decrement( "xut:key" )
		  
		  Assert.IsTrue r.Set( "xut:key", "4", 10 )
		  Assert.AreEqual 3, r.Decrement( "xut:key" )
		  
		  r.Delete "xut:key"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeleteTest()
		  dim r as new Redis_MTC
		  
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
		Sub ExistsTest()
		  dim r as new Redis_MTC
		  
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
		  
		  dim r as new Redis_MTC
		  
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
		    Assert.Pass "Unknown key"
		  end try
		  #pragma BreakOnExceptions default
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ExpireTest()
		  dim r as new Redis_MTC
		  
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
		Sub FlushAllTest()
		  //
		  // A dangerous test that we do not perform unless needed
		  //
		  return
		  dim r as new Redis_MTC
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
		  
		  dim r as new Redis_MTC
		  Assert.IsTrue r.Set( "xut:key", "value" )
		  
		  r.FlushDB
		  Assert.AreEqual -CType( 1, Int32 ), r.Keys.Ubound
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetRangeTest()
		  dim r as new Redis_MTC
		  
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
		  dim r as new Redis_MTC
		  
		  Assert.AreEqual "", r.GetSet( "xut:key", "a" )
		  Assert.AreEqual "a", r.GetSet( "xut:key", "b" )
		  Assert.AreEqual "b", r.Get( "xut:key" )
		  
		  call r.Delete( "xut:key" )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IncrementByFloatTest()
		  dim r as new Redis_MTC
		  
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
		  dim r as new Redis_MTC
		  
		  Assert.AreEqual 2, r.IncrementBy( "xut:key", 2 )
		  Assert.AreEqual 5, r.IncrementBy( "xut:key", 3 )
		  
		  Assert.IsTrue r.Set( "xut:key", "4", 10 )
		  Assert.AreEqual 10, r.IncrementBy( "xut:key", 6 )
		  
		  r.Delete "xut:key"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IncrementTest()
		  dim r as new Redis_MTC
		  
		  Assert.AreEqual 1, r.Increment( "xut:key" )
		  Assert.AreEqual 2, r.Increment( "xut:key" )
		  
		  Assert.IsTrue r.Set( "xut:key", "4", 10 )
		  Assert.AreEqual 5, r.Increment( "xut:key" )
		  
		  r.Delete "xut:key"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub KeysTest()
		  dim r as new Redis_MTC
		  
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
		Sub ObjectEncodingTest()
		  dim r as new Redis_MTC
		  
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
		  dim r as new Redis_MTC
		  
		  Assert.IsTrue r.Set( "xut:key1", "v", 30 )
		  Assert.IsTrue r.TimeToLiveMs( "xut:key1" ) <> -1
		  r.Persist( "xut:key1" )
		  Assert.AreEqual -1, r.TimeToLiveMs( "xut:key1" )
		  r.Delete "xut:key1"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PingTest()
		  dim r as new Redis_MTC
		  
		  Assert.AreSame "PONG", r.Ping
		  Assert.AreSame "something", r.Ping( "something" )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PipelineTest()
		  const kUB as Int32 = 999
		  
		  dim r as new Redis_MTC
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
		Sub RenameTest()
		  dim r as new Redis_MTC
		  
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
		Sub ScanTest()
		  dim r as new Redis_MTC
		  
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
		Sub SetBitGetBitTest()
		  dim r as new Redis_MTC
		  
		  Assert.AreEqual 0, r.SetBit( "xut:key", 0, 1 )
		  Assert.AreEqual 1, r.GetBit( "xut:key", 0 )
		  
		  Assert.AreEqual 1, r.SetBit( "xut:key", 0, 0 )
		  Assert.AreEqual 0, r.GetBit( "xut:key", 0 )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetExpiredTest()
		  dim r as new Redis_MTC
		  
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
		Sub SetGetMultipleTest()
		  dim r as new Redis_MTC
		  
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
		  dim r as new Redis_MTC
		  
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
		  dim r as new Redis_MTC
		  
		  Assert.IsTrue r.SetMultipleIfNoneExist( "xut:key1" : "value", "xut:key2" : "another" ), "Initial set"
		  Assert.IsFalse r.SetMultipleIfNoneExist( "xut:key2" : "value", "xut:key3" : "another" ), "One exists"
		  call r.Delete( "xut:key1", "xut:key2" )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetRangeTest()
		  dim r as new Redis_MTC
		  
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
		Sub StrLenTest()
		  dim r as new Redis_MTC
		  
		  Assert.AreEqual 0, r.StrLen( "xut:key" )
		  Assert.IsTrue r.Set( "xut:key", "hi" )
		  Assert.AreEqual 2, r.StrLen( "xut:key" )
		  
		  r.Delete "xut:key"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ThreadTest()
		  dim r as new Redis_MTC
		  Redis = r
		  
		  dim t as new Thread
		  AddHandler t.Run, WeakAddressOf ThreadTestRun
		  t.Run
		  while t.State = Thread.NotRunning
		    App.YieldToNextThread
		  wend
		  
		  while t.State <> Thread.NotRunning
		    Assert.IsTrue r.Set( "xut:threadtestkey", "main" )
		  wend
		  
		  RemoveHandler t.Run, WeakAddressOf ThreadTestRun
		  
		  r.Delete "xut:threadtestkey"
		  
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
		Sub TimeToLiveTest()
		  dim r as new Redis_MTC
		  
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
		  dim r as new Redis_MTC
		  
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
		  dim r as new Redis_MTC
		  
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
