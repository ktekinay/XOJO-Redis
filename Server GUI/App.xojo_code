#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Open()
		  AutoQuit = true
		  
		  //
		  // Copy the redis executable to app data
		  //
		  
		  dim resource as FolderItem = ResourcesFolder.Child( "Redis Server Mac" )
		  dim sourceServer as FolderItem
		  
		  #if TargetMacOS then
		    sourceServer = resource.Child( kServerFileName )
		  #endif
		  
		  dim dataServer as FolderItem = RedisServerFile
		  if dataServer.Exists then
		  else
		    sourceServer.CopyFileTo dataServer
		  end if
		  
		  dim dataConfig as FolderItem = RedisDefaultConfigFile
		  dim resourceConfig as FolderItem = resource.Child( "redis-default.conf" )
		  if not dataConfig.Exists or dataConfig.ModificationDate < resourceConfig.ModificationDate then
		    dataConfig.Delete
		    dataConfig = new FolderItem( dataConfig )
		    resourceConfig.CopyFileTo dataConfig
		  end if
		  
		End Sub
	#tag EndEvent


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  dim f as FolderItem = SpecialFolder.ApplicationData
			  f = f.Child( kBundleIdentifier )
			  if not f.Directory then
			    f.CreateAsFolder
			  end if
			  
			  return f
			  
			End Get
		#tag EndGetter
		DataFolder As FolderItem
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return RedisServerFile.Parent.Child( "redis-default.conf" )
			  
			End Get
		#tag EndGetter
		RedisDefaultConfigFile As FolderItem
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #if TargetMacOS or TargetLinux then
			    return App.DataFolder.Child( kServerFileName )
			  #endif
			  
			End Get
		#tag EndGetter
		RedisServerFile As FolderItem
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  dim f as FolderItem = App.ExecutableFile.Parent.Parent.Child( "Resources" )
			  return f
			  
			End Get
		#tag EndGetter
		ResourcesFolder As FolderItem
	#tag EndComputedProperty


	#tag Constant, Name = kBundleIdentifier, Type = String, Dynamic = False, Default = \"com.mactechnologies.redis-server", Scope = Public
	#tag EndConstant

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

	#tag Constant, Name = kServerFileName, Type = String, Dynamic = False, Default = \"redis-server", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
