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
		  Assert.AreNotEqual "", v, "No version info"
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
