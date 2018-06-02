#tag Class
Protected Class RedisServerTests
Inherits TestGroup
	#tag Method, Flags = &h21
		Private Sub Server_DataAvailable(sender As RedisServer_MTC, data As String)
		  #pragma unused sender
		  
		  Assert.Message data.ToText
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Server_Started(sender As RedisServer_MTC)
		  #pragma unused sender
		  
		  AsyncComplete
		  
		  WasStarted = true
		  Assert.Pass "Server started"
		  RemoveHandler Server.Started, WeakAddressOf Server_Started
		  
		  sender.Stop
		  
		  AsyncAwait 5
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Server_Stopped(sender As RedisServer_MTC)
		  #pragma unused sender
		  
		  AsyncComplete
		  
		  if not WasStarted then
		    Assert.Fail "Server was not started"
		  end if
		  
		  Assert.Pass "Server stopped"
		  RemoveHandler Server.Stopped, WeakAddressOf Server_Stopped
		  RemoveHandler Server.DataAvailable, WeakAddressOf Server_DataAvailable
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StartServerTest()
		  Server = App.NewLocalServer
		  
		  AddHandler Server.Started, WeakAddressOf Server_Started
		  AddHandler Server.DataAvailable, WeakAddressOf Server_DataAvailable
		  AddHandler Server.Stopped, WeakAddressOf Server_Stopped
		  
		  Server.Port = if( App.RedisPort = 31999, 31998, 31999 )
		  Server.Start
		  AsyncAwait 5
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub VersionTest()
		  dim s as RedisServer_MTC = App.NewLocalServer
		  dim v as string = s.RedisVersion
		  Assert.Message v.ToText
		  Assert.AreNotEqual "", v.ToText, "No version info"
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Server As RedisServer_MTC
	#tag EndProperty

	#tag Property, Flags = &h21
		Private WasStarted As Boolean
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
