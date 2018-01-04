#tag Class
Protected Class RedisBenchmarks
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub SetTest()
		  dim r as new Redis_MTC
		  
		  dim key as string = "key:__rand_int__"
		  dim data as string = "xxx"
		  
		  dim sw as new Stopwatch_MTC
		  dim reps as integer
		  
		  do 
		    if sw.ElapsedSeconds >= 1.0 then
		      exit
		    end if
		    sw.Start
		    call r.Set( key, data )
		    sw.Stop
		    reps = reps + 1
		  loop
		  
		  r.Delete key
		  
		  Assert.Pass format( reps, "#,0" ).ToText + " reps took " + format( sw.ElapsedMilliseconds, "#,0.0##" ).ToText + " ms"
		End Sub
	#tag EndMethod


End Class
#tag EndClass
