#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Activate()
		  WndServer.Show
		End Sub
	#tag EndEvent

	#tag Event
		Sub Close()
		  if ApplicationMutex isa object then
		    ApplicationMutex.Leave
		    ApplicationMutex = nil
		  end if
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub EnableMenuItems()
		  if WndServer.Visible then
		    ServerShowHide.Text = kServerHide
		  else
		    ServerShowHide.Text = kServerShow
		  end if
		  
		End Sub
	#tag EndEvent

	#tag Event
		Function HandleAppleEvent(theEvent As AppleEvent, eventClass As String, eventID As String) As Boolean
		  #pragma unused theEvent
		  
		  if eventClass = "aevt" and eventID = "rapp" then
		    WndServer.Show
		    return true
		  end if
		  
		End Function
	#tag EndEvent

	#tag Event
		Sub Open()
		  AutoQuit = true
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub OpenDocument(item As FolderItem)
		  WndServer.Show
		  WndServer.OpenDocument item
		  
		End Sub
	#tag EndEvent


	#tag MenuHandler
		Function HelpAbout() As Boolean Handles HelpAbout.Action
			WndAbout.Show
			return true
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function ServerRevealAppDataFolder() As Boolean Handles ServerRevealAppDataFolder.Action
			App.DataFolder.Launch
			
			return true
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function ServerShowHide() As Boolean Handles ServerShowHide.Action
			if WndServer.Visible then
			Hide
			else
			WndServer.Show
			end if
			
			return true
			
		End Function
	#tag EndMenuHandler


	#tag Method, Flags = &h0
		Function GetPID() As Integer
		  // This code gets the current process ID and illustrates soft declares 
		  // for macOS, Windows, and Linux. 
		  // In addition, it illustrates the use of the Alias command so that
		  // the same function name can be used in Xojo to call the OS function.
		  #If TargetMacOS Then
		    // This is not the same as a Mac OS PSN.
		    Soft Declare Function GetProcessID  Lib "libc.dylib" Alias "getpid" As Integer
		  #EndIf
		  
		  #If TargetWindows Then
		    Soft Declare Function GetProcessID Lib "Kernel32" Alias "GetCurrentProcessId" As Integer
		  #EndIf
		  
		  #If TargetLinux Then
		    Soft Declare Function GetProcessID Lib "libc.so" Alias "getpid" As Integer
		  #EndIf
		  
		  // This calls GetProcessID as defined for the OS.
		  Return GetProcessID
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Hide()
		  #if TargetMacOS then
		    dim script as string = _
		    "tell application ""System Events"" to set visible of (first process whose unix id is " + _
		    str( GetPID ) + ") to false"
		    dim sh as new Shell
		    sh.Execute "osascript -e '" + script + "'"
		  #else
		    WndServer.Minimize
		  #endif
		  
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		ApplicationMutex As Mutex
	#tag EndProperty

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

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  #if not TargetMacOS then
			    
			    return false
			    
			  #else
			    
			    static isComputed as boolean
			    static isARM as boolean
			    
			    if not isComputed then
			      dim sh as new Shell
			      sh.Execute "/usr/sbin/sysctl -a | grep 'brand_string'"
			      
			      if sh.ErrorCode <> 0 then
			        dim err as new RuntimeException
			        err.Message = "Could not run sysctl"
			        err.ErrorNumber = sh.ErrorCode
			        raise err
			      end if
			      
			      dim result as string = sh.Result.DefineEncoding( Encodings.UTF8 )
			      isARM = result.InStr( "Apple" ) <> 0
			      
			      isComputed = true
			    end if
			    
			    return isARM
			  #endif
			  
			End Get
		#tag EndGetter
		Private IsAppleARM As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return RedisServerFile.Parent.Child( "redis-server-gui.conf" )
			  
			End Get
		#tag EndGetter
		RedisDefaultConfigFile As FolderItem
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  dim server as FolderItem
			  dim resource as FolderItem
			  
			  #if TargetMacOS then
			    if IsAppleARM then
			      resource = ResourcesFolder.Child( "Redis Server Mac ARM" )
			    else
			      resource = ResourcesFolder.Child( "Redis Server Mac Intel" )
			    end if
			  #elseif TargetWindows then
			    resource = ResourcesFolder.Child( "Redis Server Windows" )
			  #endif
			  
			  server = resource.Child( kServerFileName )
			  return server
			End Get
		#tag EndGetter
		RedisServerFile As FolderItem
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  dim f as FolderItem
			  #if TargetMacOS then
			    f = App.ExecutableFile.Parent.Parent.Child( "Resources" )
			  #else
			    dim appName as string = App.ExecutableFile.Name
			    appName = appName.Replace( ".exe", "" )
			    f = App.ExecutableFile.Parent.Child( appName + " Resources" )
			  #endif
			  
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

	#tag Constant, Name = kServerDefaultConfig, Type = String, Dynamic = False, Default = \"Start With Default Config", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kServerFileName, Type = String, Dynamic = False, Default = \"redis-server", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"redis-server.exe"
	#tag EndConstant

	#tag Constant, Name = kServerHide, Type = String, Dynamic = False, Default = \"Hide", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Minimize"
	#tag EndConstant

	#tag Constant, Name = kServerShow, Type = String, Dynamic = False, Default = \"Show", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kServerStartWithConfig, Type = String, Dynamic = False, Default = \"Start With Config...", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
