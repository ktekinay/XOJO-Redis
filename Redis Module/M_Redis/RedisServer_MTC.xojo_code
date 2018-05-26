#tag Class
Class RedisServer_MTC
	#tag Method, Flags = &h21
		Private Sub Destructor()
		  Stop
		  TeardownServerShell
		  
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
		  const kReadyMarker as string = "Server initialized"
		  
		  dim stuff as string = sender.ReadAll.DefineEncoding( Encodings.UTF8 ).Trim
		  
		  if stuff.InStr( kReadyMarker ) <> 0 then
		    mIsReady = true
		    RaiseEvent Started
		  end if
		  
		  mLastMessage = stuff
		  RaiseEvent DataAvailable( stuff )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Start()
		  if ServerShell is nil then
		    ServerShell = new Shell
		    ServerShell.Mode = 2 // Interactive
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
		  
		  dim serverPath as string = RedisServerFile.ShellPath
		  dim configPath as string = if( ConfigFile is nil, "", ConfigFile.ShellPath )
		  
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
		  
		  #if TargetWindows then
		    
		    #pragma error "Finish this!!"
		    
		  #else
		    
		    dim usePort as integer = if( Port > 0, Port, 0 )
		    
		    dim paramString as string = _
		    if( configPath <> "", configPath + " ", "" ) + _
		    if( LogLevelString <> "", "--loglevel " + logLevelString + " ", "" ) + _
		    if( usePort <> 0, "--port " + str( usePort ) + " ", "" ) + _
		    ParametersToString
		    paramString = paramString.Trim
		    
		    ServerShell.Execute serverPath, paramString
		  #endif
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Stop(force As Boolean = False)
		  if IsRunning then
		    ServerShell.Write ChrB( 3 )
		    ServerShell.Poll
		    if force then
		      ServerShell.Close
		    end if
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub TeardownServerShell()
		  //
		  // Assumes it's ready to be torn down
		  //
		  
		  mIsReady = false
		  
		  if ServerShell isa object then
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

	#tag Property, Flags = &h0
		LogLevel As LogLevels = LogLevels.Default
	#tag EndProperty

	#tag Property, Flags = &h21
		Attributes( hidden ) Private mIsReady As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Attributes( hidden ) Private mLastMessage As String
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

	#tag Property, Flags = &h0
		Port As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		RedisServerFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private ServerShell As Shell
	#tag EndProperty


	#tag Constant, Name = kDefaultPort, Type = Double, Dynamic = False, Default = \"6379", Scope = Public
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
	#tag EndViewBehavior
End Class
#tag EndClass
