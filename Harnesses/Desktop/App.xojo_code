#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Open()
		  LocalServer = newLocalServer
		  
		  XojoUnitTestWindow.Show
		  WndRedisSettings.Show
		  WndRedisSettings.Left = XojoUnitTestWindow.Left + XojoUnitTestWindow.Width
		  XojoUnitTestWindow.Show
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Function NewLocalServer() As RedisServer_MTC
		  dim serverFile as FolderItem = App.ResourcesFolder.Child( "Redis Server Mac" ).Child( "redis-server" )
		  dim configFile as FolderItem = App.ResourcesFolder.Child( "redis-port-31999-no-save.conf" )
		  
		  dim server as new RedisServer_MTC
		  server.RedisServerFile = serverFile
		  server.ConfigFile = configFile
		  
		  return server
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		CommandDict As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		LocalServer As RedisServer_MTC
	#tag EndProperty

	#tag Property, Flags = &h0
		RedisAddress As String = "localhost"
	#tag EndProperty

	#tag Property, Flags = &h0
		RedisPassword As String
	#tag EndProperty

	#tag Property, Flags = &h0
		RedisPort As Integer = 6379
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #if TargetMacOS then
			    
			    dim contents as FolderItem = App.ExecutableFile.Parent.Parent
			    return contents.Child( "Resources" )
			    
			  #else
			    
			    dim name as string = App.ExecutableFile.Name
			    if name.Right( 4 ) = ".exe" then
			      name = name.Left( name.Len - 4 )
			    end if
			    
			    dim parent as FolderItem = App.ExecutableFile.Parent
			    dim resourcesName as string = name + " Resources"
			    dim resourcesFolder as FolderItem = parent.Child( resourcesName )
			    return resourcesFolder
			    
			  #endif
			End Get
		#tag EndGetter
		ResourcesFolder As FolderItem
	#tag EndComputedProperty


	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="RedisAddress"
			Group="Behavior"
			InitialValue="localhost"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RedisPassword"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RedisPort"
			Group="Behavior"
			InitialValue="6379"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
