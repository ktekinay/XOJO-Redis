#tag Class
Protected Class RedisPipelineBenchmarks
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub SetTest()
		  SetTestBase kPipelines, kReps
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetTestBase(pipelines As Integer, reps As Integer)
		  #if not DebugBuild then
		    #pragma BackgroundTasks false
		    #pragma NilObjectChecking false
		    #pragma StackOverflowChecking false
		    #pragma BoundsChecking false
		  #endif
		  
		  dim r as new Redis_MTC
		  r.StartPipeline( pipelines )
		  
		  Assert.Message "With " + pipelines.ToText + " pipelines"
		  
		  dim key as string = "xut:__rand_int__"
		  dim data as string = "xxx"
		  
		  'call r.Set( key, data )
		  'dim cmd as string = r.LastCommand
		  'dim cmd as string = "SET " + key + " " + data
		  'dim params() as string = array( key, data )
		  
		  dim sw as new Stopwatch_MTC
		  dim swFlush as new Stopwatch_MTC
		  
		  for i as integer = 1 to reps
		    sw.Start
		    'call r.Execute( "SET", params )
		    'call r.Execute( "SET", key, data )
		    'call r.Execute( cmd, nil )
		    call r.Set( key, data )
		    sw.Stop
		  next i
		  
		  swFlush.Start
		  dim arr() as variant = r.FlushPipeline( false )
		  swFlush.Stop
		  
		  Assert.AreEqual CType( reps - 1, Int32 ), arr.Ubound
		  
		  r.Delete key
		  
		  dim avg as double = reps / sw.ElapsedSeconds
		  Assert.Pass format( reps, "#,0" ).ToText + " keys took " + _
		  format( sw.ElapsedSeconds, "#,0.0##" ).ToText + "s, avg " + _
		  format( avg, "#,0.0##" ).ToText + "/s"
		  Assert.Pass "Flush took " + format( swFlush.ElapsedSeconds, "#,0.0##" ).ToText + "s"
		  
		  dim combined as double = sw.ElapsedSeconds + swFlush.ElapsedSeconds
		  avg = reps / combined
		  Assert.Pass "Combined took " + _
		  format( combined, "#,0.0##" ).ToText + "s, avg " + _
		  format( avg, "#,0.0##" ).ToText + "/s"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetWith1Test()
		  SetTestBase 1, kReps / 5
		End Sub
	#tag EndMethod


	#tag Constant, Name = kPipelines, Type = Double, Dynamic = False, Default = \"10", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kReps, Type = Double, Dynamic = False, Default = \"100000", Scope = Private
	#tag EndConstant


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
