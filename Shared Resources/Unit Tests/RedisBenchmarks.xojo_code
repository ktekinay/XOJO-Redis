#tag Class
Protected Class RedisBenchmarks
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub PingBulkTest()
		  #if not DebugBuild then
		    #pragma BackgroundTasks false
		    #pragma NilObjectChecking false
		    #pragma StackOverflowChecking false
		    #pragma BoundsChecking false
		  #endif
		  
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  dim sw as new Stopwatch_MTC
		  
		  for i as integer = 1 to kReps
		    sw.Start
		    call r.Ping( "PONG" )
		    sw.Stop
		  next
		  
		  dim avg as double = kReps / sw.ElapsedSeconds
		  Assert.Pass format( kReps, "#,0" ).ToText + " requests took " + format( sw.ElapsedSeconds, "#,0.0##" ).ToText + "s, avg " + _
		  format( avg, "#,0.0##" ).ToText + "/s"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PingInlineTest()
		  #if not DebugBuild then
		    #pragma BackgroundTasks false
		    #pragma NilObjectChecking false
		    #pragma StackOverflowChecking false
		    #pragma BoundsChecking false
		  #endif
		  
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  dim sw as new Stopwatch_MTC
		  
		  for i as integer = 1 to kReps
		    sw.Start
		    call r.Ping
		    sw.Stop
		  next
		  
		  dim avg as double = kReps / sw.ElapsedSeconds
		  Assert.Pass format( kReps, "#,0" ).ToText + " requests took " + format( sw.ElapsedSeconds, "#,0.0##" ).ToText + "s, avg " + _
		  format( avg, "#,0.0##" ).ToText + "/s"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ScanTest()
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  dim keys() as string = r.Scan( "xut:*" )
		  call r.Delete( keys )
		  
		  const kUB as Int32 = 99999
		  dim arrCount as integer = kUB + 1
		  Assert.Message arrCount.ToText( Xojo.Core.Locale.Current, "#,###,##0" ) + " items"
		  
		  r.StartPipeline 50
		  for i as integer = 0 to kUB
		    call r.Set( "xut:key" + str( i ), "value", 5000 )
		  next
		  call r.FlushPipeline( false )
		  
		  dim sw as new Stopwatch_MTC
		  sw.Start
		  keys = r.Scan( "xut:*" )
		  sw.Stop
		  dim elapsed as double = sw.ElapsedMilliseconds
		  
		  Assert.AreEqual CType( kUB, Int32 ), keys.Ubound
		  Assert.Message "Scan (default) took " + _
		  elapsed.ToText( Xojo.Core.Locale.Current, "#,###,##0.0##" ) + " ms"
		  
		  sw.Reset
		  sw.Start
		  keys = r.Scan( "xut:*", 1000 )
		  sw.Stop
		  elapsed = sw.ElapsedMilliseconds
		  
		  Assert.AreEqual CType( kUB, Int32 ), keys.Ubound
		  Assert.Message "Scan (1000) took " + _
		  elapsed.ToText( Xojo.Core.Locale.Current, "#,###,##0.0##" ) + " ms"
		  
		  call r.Delete( keys )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetTest()
		  #if not DebugBuild then
		    #pragma BackgroundTasks false
		    #pragma NilObjectChecking false
		    #pragma StackOverflowChecking false
		    #pragma BoundsChecking false
		  #endif
		  
		  dim r as new Redis_MTC( App.RedisPassword, App.RedisAddress, App.RedisPort )
		  
		  dim key as string = "xut:__rand_int__"
		  dim data as string = "xxx"
		  
		  dim sw as new Stopwatch_MTC
		  
		  for i as integer = 1 to kReps
		    sw.Start
		    call r.Set( key, data )
		    sw.Stop
		  next
		  
		  r.Delete key
		  
		  dim avg as double = kReps / sw.ElapsedSeconds
		  Assert.Pass format( kReps, "#,0" ).ToText + " keys took " + format( sw.ElapsedSeconds, "#,0.0##" ).ToText + "s, avg " + _
		  format( avg, "#,0.0##" ).ToText + "/s"
		  
		End Sub
	#tag EndMethod


	#tag Constant, Name = kReps, Type = Double, Dynamic = False, Default = \"10000", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Duration"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FailedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IncludeGroup"
			Visible=false
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsRunning"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="NotImplementedCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PassedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="RunTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SkippedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="StopTestOnFail"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
