#tag Class
Class RedisServer_MTC
	#tag Method, Flags = &h21
		Private Sub Destructor()
		  #if TargetWindows then
		    if IsRunning then
		      Kill
		    end if
		  #else
		    Stop
		  #endif
		  
		  TeardownServerShell
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Kill()
		  //
		  // Will force a hard kill
		  //
		  
		  if IsRunning then
		    //
		    // Make sure it's not going to quit on its own
		    //
		    ServerShell.Poll
		    ServerShell.Poll
		  end if
		  
		  if IsRunning then
		    dim sh as new Shell
		    #if TargetWindows then
		      sh.Execute "taskkill /f /pid " + PID
		    #else
		      sh.Execute "kill -9 " + PID
		    #endif
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function ParseConfigFile(config As FolderItem) As Dictionary
		  dim tis as TextInputStream = TextInputStream.Open( config )
		  dim contents as string = tis.ReadAll( Encodings.UTF8 )
		  tis.Close
		  tis = nil
		  
		  dim rx as new RegEx
		  rx.SearchPattern = "(?mi-Us)^[\x20\t]*(\w[\w\-]*)[\x20\t]+(\S+)"
		  
		  dim r as new Dictionary
		  
		  dim match as RegExMatch = rx.Search( contents )
		  while match isa object
		    r.Value( match.SubExpressionString( 1 ) )  = match.SubExpressionString( 2 )
		    match = rx.Search
		  wend
		  
		  return r
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PopulateConnectedPort()
		  //
		  // Populates mConnectedPort
		  //
		  // Order is important here
		  //
		  
		  if not IsRunning then
		    mConnectedPort = 0
		  elseif Port > 0 then
		    mConnectedPort = Port
		  elseif Parameters isa object and Parameters.Lookup( "port", 0 ).IntegerValue > 0 then
		    mConnectedPort = Parameters.Value( "port" ).IntegerValue
		  elseif ConfigFile isa object then
		    dim params as Dictionary = ParseConfigFile( ConfigFile )
		    mConnectedPort = params.Lookup( "port", 0 ).IntegerValue
		  else
		    mConnectedPort = M_Redis.Redis_MTC.kDefaultPort
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RedisVersion() As String
		  if RedisServerFile is nil then
		    return ""
		  end if
		  
		  dim sh as new Shell
		  sh.Execute RedisServerFile.ShellPath, "--version"
		  dim version as string = sh.Result.DefineEncoding( Encodings.UTF8 ).Trim
		  return version
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ServerShell_Completed(sender As Shell)
		  #pragma unused sender
		  
		  TeardownServerShell
		  
		  RaiseEvent Stopped
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ServerShell_DataAvailable(sender As Shell)
		  #if TargetWindows then
		    const kReadyMarker as string = "Server started"
		  #else
		    const kReadyMarker as string = "Server initialized"
		  #endif
		  
		  dim stuff as string = sender.ReadAll.DefineEncoding( Encodings.UTF8 )
		  
		  #if TargetWindows then
		    if PID = "" then
		      static rx as RegEx
		      if rx is nil then
		        rx = new RegEx
		        rx.SearchPattern = "^\[(\d+)\]"
		      end if
		      dim match as RegExMatch = rx.Search( stuff )
		      if match isa RegExMatch then
		        mPID = match.SubExpressionString( 1 )
		      end if
		    end if
		  #endif
		  
		  if stuff.InStr( kReadyMarker ) <> 0 then
		    PopulateConnectedPort
		    mIsReady = true
		    RaiseEvent Started
		  end if
		  
		  mLastMessage = stuff
		  RaiseEvent DataAvailable( stuff )
		  
		End Sub
	#tag EndMethod

	#tag ExternalMethod, Flags = &h21
		Private Declare Function SetConsoleCtrlHandler Lib kWindowsLib (handler As Ptr, add As Boolean) As Boolean
	#tag EndExternalMethod

	#tag Method, Flags = &h0
		Sub Start()
		  if ServerShell is nil then
		    ServerShell = new Shell
		    ServerShell.Mode = 2 // Interactive
		    #if TargetWindows then
		      ServerShell.Canonical = true
		    #endif
		    AddHandler ServerShell.DataAvailable, WeakAddressOf ServerShell_DataAvailable
		    AddHandler ServerShell.Completed, WeakAddressOf ServerShell_Completed
		  end if
		  
		  if IsRunning then
		    raise new RedisException( "This server is already running" )
		  end if
		  
		  if RedisServerFile is nil then
		    raise new RedisException( "No redis server executable specified" )
		  end if
		  
		  mIsReady = false
		  mConnectedPort = 0
		  mPID = ""
		  
		  dim serverPath as string = ShellPathOf( RedisServerFile )
		  dim configPath as string = ShellPathOf( ConfigFile )
		  
		  dim logLevelString as string
		  select case LogLevel
		  case LogLevels.Debug
		    logLevelString = "debug"
		  case LogLevels.Notice
		    logLevelString = "notice"
		  case LogLevels.Verbose
		    logLevelString = "verbose"
		  case LogLevels.Warning
		    logLevelString = "warning"
		  end select
		  
		  dim usePort as integer = if( Port > 0, Port, 0 )
		  
		  dim paramString as string = ParametersToString
		  if paramString <> "" then
		    paramString = paramString + " "
		  end if
		  
		  paramString = _
		  if( configPath <> "", configPath + " ", "" ) + _
		  paramString + _
		  if( LogLevelString <> "", "--loglevel " + logLevelString + " ", "" ) + _
		  if( usePort <> 0, "--port " + str( usePort ) + " ", "" ) + _
		  if( WorkingDirectory isa object, "--dir " + ShellPathOf( WorkingDirectory ) + " ", "") + _
		  if( DBFilename.Trim <> "", "--dbfilename """ + DBFilename + """ ", "" )
		  paramString = paramString.Trim
		  
		  mLaunchCommand = serverPath + " " + paramString
		  ServerShell.Execute LaunchCommand
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Stop(force As Boolean = False)
		  if IsRunning then
		    #if TargetWindows then
		      declare function AttachConsole lib kWindowsLib (dbProcessId As UInt32) As Boolean
		      declare function GenerateConsoleCtrlEvent lib kWindowsLib (dwCtrlEvent as Int32, dwProcessGroupId As UInt32) As Boolean
		      
		      if AttachConsole( PID.Val ) then
		        call SetConsoleCtrlHandler( nil, true )
		        call GenerateConsoleCtrlEvent( 0, 0 )
		        DoWindowsTeardown = true
		      end if
		      
		    #else
		      static ctrlC as string = ChrB( 3 ).DefineEncoding( nil )
		      ServerShell.Write ctrlC
		    #endif
		    
		    ServerShell.Poll
		    
		    if force then
		      Kill
		    end if
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub TeardownServerShell()
		  //
		  // Assumes it's ready to be torn down
		  //
		  
		  #if TargetWindows then
		    if DoWindowsTeardown then
		      declare function FreeConsole lib kWindowsLib () As Boolean
		      
		      call SetConsoleCtrlHandler( nil, false )
		      call FreeConsole()
		      
		      DoWindowsTeardown = false
		    end if
		  #endif
		  
		  mIsReady = false
		  mPID = ""
		  mConnectedPort = 0
		  
		  if ServerShell isa object then
		    if ServerShell.IsRunning then
		      Kill
		    end if
		    RemoveHandler ServerShell.DataAvailable, WeakAddressOf ServerShell_DataAvailable
		    RemoveHandler ServerShell.Completed, WeakAddressOf ServerShell_Completed
		    ServerShell = nil
		  end if
		  
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event DataAvailable(data As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Started()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Stopped()
	#tag EndHook


	#tag Property, Flags = &h0
		ConfigFile As FolderItem
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mConnectedPort
			End Get
		#tag EndGetter
		ConnectedPort As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		DBFilename As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private DoWindowsTeardown As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  if ServerShell isa object then
			    return ServerShell.ErrorCode
			  else
			    return 0
			  end if
			  
			End Get
		#tag EndGetter
		ErrorCode As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return IsRunning and mIsReady
			  
			End Get
		#tag EndGetter
		IsReady As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  if ServerShell is nil then
			    return false
			  else
			    return ServerShell.IsRunning
			  end if
			  
			End Get
		#tag EndGetter
		IsRunning As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mLastMessage
			End Get
		#tag EndGetter
		LastMessage As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mLaunchCommand
			End Get
		#tag EndGetter
		LaunchCommand As String
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		LogLevel As LogLevels = LogLevels.Default
	#tag EndProperty

	#tag Property, Flags = &h21
		Attributes( hidden ) Private mConnectedPort As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Attributes( hidden ) Private mIsReady As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Attributes( hidden ) Private mLastMessage As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Attributes( hidden ) Private mLaunchCommand As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Attributes( hidden ) Private mPID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Parameters As Dictionary
	#tag EndProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  if Parameters is nil then
			    return ""
			  end if
			  
			  dim keys() as variant = Parameters.Keys
			  dim values() as variant = Parameters.Values
			  
			  dim builder() as string
			  
			  for i as integer = 0 to keys.Ubound
			    dim thisKey as string = keys( i )
			    if thisKey = "" then
			      continue for i
			    end if
			    
			    if thisKey.InStr( "'" ) <> 0 or thisKey.InStr( "\" ) <> 0 then
			      raise new RedisException( "Invalid parameter key: " + thisKey )
			    end if
			    
			    dim keyLen as integer = thisKey.Len
			    
			    if keyLen = 2 and thisKey.Left( 1 ) = "-" then
			      //
			      // It's already good
			      //
			      
			    elseif thisKey.Left( 2 ) = "--" then
			      //
			      // Also good
			      //
			      
			    elseif keyLen = 1 then
			      thisKey = "-" + thisKey
			      
			    else
			      thisKey = "--" + thisKey
			      
			    end if
			    
			    builder.Append thisKey
			    
			    dim thisValue as string
			    if values( i ).Type = Variant.TypeObject and values( i ) isa FolderItem then
			      thisValue = FolderItem( values( i ) ).NativePath
			    else
			      thisValue = values( i ).StringValue
			    end if
			    
			    if thisValue <> "" then
			      thisValue = "'" + thisValue.ReplaceAll( "\", "'\\'" ).ReplaceAll( "'", "'\''" ) + "'"
			      builder.Append thisValue
			    end if
			  next
			  
			  dim paramString as string = join( builder, " " )
			  return paramString
			  
			End Get
		#tag EndGetter
		Private ParametersToString As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #if TargetWindows then
			    return mPID
			  #else
			    if IsRunning then
			      return str( ServerShell.PID )
			    else
			      return ""
			    end if
			  #endif
			  
			End Get
		#tag EndGetter
		PID As String
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		Port As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		RedisServerFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private ServerShell As Shell
	#tag EndProperty

	#tag Property, Flags = &h0
		WorkingDirectory As FolderItem
	#tag EndProperty


	#tag Constant, Name = kDefaultPort, Type = Double, Dynamic = False, Default = \"6379", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kWindowsLib, Type = String, Dynamic = False, Default = \"kernel32.dll", Scope = Private
	#tag EndConstant


	#tag Enum, Name = LogLevels, Type = Integer, Flags = &h0
		Default
		  Debug
		  Verbose
		  Notice
		Warning
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Port"
			Group="Behavior"
			InitialValue="kDefaultPort"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LogLevel"
			Group="Behavior"
			InitialValue="LogLevels.Default"
			Type="LogLevels"
			EditorType="Enum"
			#tag EnumValues
				"0 - Default"
				"1 - Debug"
				"2 - Verbose"
				"3 - Notice"
				"4 - Warning"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsRunning"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ErrorCode"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastMessage"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsReady"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LaunchCommand"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DBFilename"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="PID"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ConnectedPort"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
