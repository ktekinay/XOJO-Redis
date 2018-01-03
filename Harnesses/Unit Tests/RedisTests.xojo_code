#tag Class
Protected Class RedisTests
Inherits TestGroup
	#tag Event
		Sub Setup()
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
		Sub DeleteTest()
		  dim r as new Redis_MTC
		  
		  Assert.IsTrue r.Set( "xut:key", "value" )
		  r.Delete( "xut:key" )
		  Assert.AreEqual Ctype( -1, Int32 ), r.Keys.Ubound
		  
		  Assert.IsTrue r.Set( "xut:key1", "value1" )
		  Assert.IsTrue r.Set( "xut:key2", "value2" )
		  Assert.AreEqual 2, r.Delete( "xut:key1", "xut:key2", "xut:key3" )
		  
		  r.SetMultiple "xut:key1" : "value", "xut:key2" : "other"
		  Assert.AreEqual Ctype( 1, Int32 ), r.Keys.Ubound
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
		Sub FlushAllTest()
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
		Sub KeysTest()
		  dim r as new Redis_MTC
		  
		  dim keys() as string = r.Keys
		  Assert.AreEqual CType( -1, Int32 ), keys.Ubound
		  
		  Assert.IsTrue r.Set( "xut:key", "value" )
		  Assert.IsTrue r.Set( "xut:key2", "another" )
		  
		  keys = r.Keys
		  Assert.AreEqual CType( 1, Int32 ), keys.Ubound
		  
		  keys = r.Keys( "*2" )
		  Assert.AreEqual CType( 0, Int32 ), keys.Ubound
		  
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
		Sub PingTest()
		  dim r as new Redis_MTC
		  
		  Assert.AreSame "PONG", r.Ping
		  Assert.AreSame "something", r.Ping( "something" )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RenameTest()
		  dim r as new Redis_MTC
		  
		  Assert.IsTrue r.Set( "xut:key", "value" )
		  r.Rename "xut:key", "xut:key1"
		  Assert.AreSame "value", r.Get( "xut:key1" )
		  
		  r.FlushAll
		  
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
