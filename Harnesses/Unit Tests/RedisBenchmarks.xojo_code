#tag Class
Protected Class RedisBenchmarks
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub SetTest()
		  dim r as new Redis_MTC
		  
		  dim key as string = "key:__rand_int__"
		  dim data as string = "xxx"
		  
		  const kReps as integer = 100000
		  
		  dim sw as new Stopwatch_MTC
		  for i as integer = 1 to kReps
		    sw.Start
		    call r.Set( key, data )
		    sw.Stop
		  next
		  
		  r.Delete key
		  
		  Assert.Pass format( kReps, "#,0" ).ToText + " reps took " + format( sw.ElapsedMilliseconds, "#,0.0##" ).ToText + " ms"
		End Sub
	#tag EndMethod


End Class
#tag EndClass
