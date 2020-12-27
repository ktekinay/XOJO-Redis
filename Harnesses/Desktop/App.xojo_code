#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Open()
		  LocalServer = NewLocalServer
		  
		  XojoUnitTestWindow.Show
		  WndRedisSettings.Show
		  WndRedisSettings.Left = XojoUnitTestWindow.Left + XojoUnitTestWindow.Width
		  XojoUnitTestWindow.Show
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Function NewLocalServer() As RedisServer_MTC
		  dim serverFile as FolderItem 
		  #if TargetMacOS then
		    
		    dim folderName as string  = "Redis Server Mac "
		    if IsAppleARM then
		      folderName = folderName + "ARM"
		    else
		      folderName = folderName + "Intel"
		    end if
		    
		    serverFile = App.ResourcesFolder.Child( folderName ).Child( "redis-server" )
		  #else
		    serverFile = App.ResourcesFolder.Child( "Redis Server Windows" ).Child( "redis-server.exe" )
		  #endif
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

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  #if not TargetMacOS then
			    
			    return false
			    
			  #else
			    
			    dim rx as new RegEx
			    rx.SearchPattern = "^\x20*Chip: .*\Apple\b"
			    
			    dim sh as new Shell
			    sh.Execute "/usr/sbin/system_profiler SPHardwareDataType"
			    
			    if sh.ErrorCode <> 0 then
			      dim err as new RuntimeException
			      err.Message = "Could not run system_profiler"
			      err.ErrorNumber = sh.ErrorCode
			      raise err 
			    end if
			    
			    return rx.Search( sh.Result ) isa RegExMatch
			    
			  #endif
			  
			End Get
		#tag EndGetter
		Private IsAppleARM As Boolean
	#tag EndComputedProperty

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
			Visible=false
			Group="Behavior"
			InitialValue="localhost"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RedisPassword"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RedisPort"
			Visible=false
			Group="Behavior"
			InitialValue="6379"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
