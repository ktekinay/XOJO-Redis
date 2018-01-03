#tag Class
Class Redis_MTC
	#tag Method, Flags = &h0
		Sub Auth(pw As String)
		  dim cmd as string = BuildArray( "AUTH", pw )
		  call Perform( cmd )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildArray(ParamArray parts() As String) As String
		  return BuildArray( parts )
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildArray(parts() As String) As String
		  dim raw() as string
		  raw.Append "*"
		  raw.Append str( parts.Ubound + 1 )
		  raw.Append EOL
		  
		  for i as integer = 0 to parts.Ubound
		    dim part as string = parts( i )
		    raw.Append "$"
		    raw.Append str( part.LenB )
		    raw.Append EOL
		    raw.Append part
		    if i < parts.Ubound then
		      raw.Append EOL
		    end if
		  next
		  
		  return join( raw, "" )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ConfigGet(pattern As String = "*") As Dictionary
		  if pattern = "" then
		    pattern = "*"
		  end if
		  
		  dim cmd as string = BuildArray( "CONFIG", "GET", pattern )
		  dim arr() as variant = Perform( cmd )
		  
		  dim r as new Dictionary
		  for i as integer = 0 to arr.Ubound step 2
		    r.Value( arr( i ).StringValue ) = arr( i + 1 ).StringValue
		  next
		  
		  return r
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ConfigSet(parameter As String, value As String)
		  dim cmd as string = BuildArray( "CONFIG", "SET", parameter, value )
		  call Perform( cmd )
		  
		  if parameter = kConfigRequirePass and value <> "" then
		    Auth value
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pw As String = "", host As String = kDefaultHost, port As Integer = kDefaultPort)
		  if host = "" then
		    host = kDefaultHost
		  end if
		  if port <= 0 then
		    port = kDefaultPort
		  end if
		  
		  CommandSemaphore = new Semaphore( 1 )
		  
		  Socket = new TCPSocket
		  Socket.Address = host
		  Socket.Port = port
		  AddHandler Socket.DataAvailable, WeakAddressOf Socket_DataAvailable
		  
		  Socket.Connect
		  dim startMs as double = Microseconds
		  do
		    Socket.Poll
		  loop until Socket.IsConnected or ( Microseconds - startMs ) > 500000
		  
		  if not Socket.IsConnected then
		    RaiseException 0, "Could not connect to host """ + host + " on port " + str(port)
		  end if
		  
		  if pw <> "" then
		    Auth pw
		  end if
		  
		  dim serverInfo as string = Info( kSectionServer )
		  
		  if serverInfo = "" then
		    RaiseException 0, "Could not get a response from host """ + host + " on port " + str(port)
		  end if
		  
		  dim rxVersion as new RegEx
		  rxVersion.SearchPattern = "^redis_version:(.*)"
		  dim match as RegExMatch = rxVersion.Search( serverInfo )
		  if match isa RegExMatch then
		    zVersion = match.SubExpressionString( 1 )
		    dim parts() as string = Version.Split( "." )
		    if parts.Ubound < 2 then
		      redim parts( 2 )
		    end if
		    
		    MajorVersion = parts( 0 ).Val
		    MinorVersion = parts( 1 ).Val
		    BugVersion = parts( 2 ).Val
		  end if
		  
		  InitCommandDelete
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Delete(keys() As String) As Integer
		  //
		  // Will ignore an empty array
		  // That way you can feed it the results from a Scan or Keys
		  //
		  
		  if keys.Ubound = -1 then
		    return 0
		  else
		    return Execute( CommandDelete, keys )
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Delete(key As String)
		  dim cmd as string = CommandDelete + " " + Escape( key )
		  call Perform( cmd )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Delete(key1 As String, key2 As String, ParamArray moreKeys() As String) As Integer
		  dim keys() as string = array( key1, key2 )
		  for each key as string in moreKeys
		    keys.Append key
		  next
		  return Delete( keys )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  if Socket isa object then
		    Socket.Close
		    RemoveHandler Socket.DataAvailable, WeakAddressOf Socket_DataAvailable
		    Socket = nil
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Escape(v As Variant) As String
		  //
		  // Handle encoding
		  //
		  
		  dim s as string
		  
		  if v.Type = Variant.TypeText then
		    dim t as text = v.TextValue
		    s = t
		    v = s
		  end if
		  
		  if v.Type = Variant.TypeString then
		    s = v.StringValue
		    
		    if s.Encoding is nil then
		      if Encodings.UTF8.IsValidData( s ) then
		        s = s.DefineEncoding( Encodings.UTF8 )
		      else
		        s = s.DefineEncoding( Encodings.SystemDefault )
		        s = s.ConvertEncoding( Encodings.UTF8 )
		      end if
		      
		    elseif s.Encoding <> Encodings.UTF8 then
		      s = s.ConvertEncoding( Encodings.UTF8 )
		      
		    end if
		    
		    s = s.ReplaceAll( "\", "\\" )
		    s = s.ReplaceAll( """", "\""" )
		    s = """" + s + """"
		    
		  else
		    s = v.StringValue
		    
		  end if
		  
		  return s
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Execute(command As String, parameters() As String) As Variant
		  dim parts() as string = array( command.Trim )
		  for i as integer = 0 to parameters.Ubound
		    parts.Append parameters( i )
		  next
		  
		  dim cmd as string = BuildArray( parts )
		  return Perform( cmd )
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Execute(command As String, ParamArray parameters() As String) As Variant
		  return Execute( command, parameters )
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Exists(key As String) As Boolean
		  dim cmd as string = BuildArray( "EXISTS", key )
		  dim r as integer = Perform( cmd )
		  return r <> 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Exists(key1 As String, key2 As String, ParamArray moreKeys() As String) As Integer
		  dim parts() as string = array( "EXISTS", key1, key2 )
		  for each key as string in moreKeys
		    parts.Append key
		  next
		  
		  dim cmd as string = BuildArray( parts )
		  return Perform( cmd ).IntegerValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FlushAll()
		  if CommandFlushAll = "" then
		    CommandFlushAll = "FLUSHALL" + if( MajorVersion >= 4, " ASYNC", "" )
		  end if
		  call Perform( CommandFlushAll )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FlushDB()
		  if CommandFlushDB = "" then
		    CommandFlushDB = "FLUSHDB" + if( MajorVersion >= 4, " ASYNC", "" )
		  end if
		  call Perform( CommandFlushDB )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(key As String) As String
		  dim cmd as string = BuildArray( "GET", key )
		  dim value as variant = Perform( cmd )
		  if value.IsNull then
		    raise new KeyNotFoundException
		  else
		    return value.StringValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetMultiple(ParamArray keys() As String) As Variant()
		  dim parts() as string = array( "MGET" )
		  
		  for i as integer = 0 to keys.Ubound
		    dim key as string = keys( i )
		    parts.Append key
		  next i
		  
		  dim cmd as string = BuildArray( parts )
		  dim arr() as variant = Perform( cmd )
		  return arr
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetReponse() As Variant
		  #if DebugBuild then
		    const kWaitMs = 60.0 * 1000000.0
		  #else
		    const kWaitMs = 0.5 * 1000000.0
		  #endif
		  
		  dim raw as string
		  
		  dim t as Thread = App.CurrentThread
		  CurrentThread = t
		  
		  if t is nil then
		    dim startMs as double = Microseconds
		    
		    do
		      Socket.Poll
		      raw = raw + Socket.ReadAll
		    loop until raw.RightB( EOL.LenB ) = EOL or ( Microseconds - startMs ) > kWaitMs
		    
		  else
		    
		    t.Sleep kWaitMs / 1000.0, true
		    raw = Socket.ReadAll
		    
		  end if
		  
		  if LastErrorCode <> 0 then
		    RaiseException LastErrorCode, "Unknown error"
		    return nil
		    
		  else
		    
		    dim pos as integer = 1
		    dim v as variant = InterpretResponse( raw, pos )
		    return v
		    
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Info(section As String = "") As String
		  dim cmd as string = "INFO" + if( section <> "", " " + section, "" )
		  return Perform( cmd ).StringValue
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitCommandDelete()
		  if CommandDelete = "" then
		    if MajorVersion >= 4 then
		      CommandDelete = "UNLINK"
		    else
		      CommandDelete = "DEL"
		    end if
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function InterpretResponse(s As String, ByRef pos As Integer) As Variant
		  static eolLen as integer = EOL.LenB
		  
		  dim r as variant
		  
		  if pos < 2 then
		    pos = 1
		    s = s.DefineEncoding( Encodings.UTF8 )
		  end if
		  
		  dim firstLine as string
		  dim eolPos as integer = s.InStrB( pos, EOL )
		  if eolPos = 0 then
		    eolPos = s.LenB + 1
		  end if
		  firstLine = s.MidB( pos, eolPos - pos )
		  dim firstChar as string = firstLine.LeftB( 1 )
		  
		  select case firstChar
		  case ":" // Integer
		    dim i as Int64 = firstLine.MidB( 2 ).Val
		    r = i
		    pos = pos + firstLine.LenB + eolLen
		    
		  case "+" // Simple string
		    r = firstLine.MidB( 2 )
		    pos = pos + firstLine.LenB + eolLen
		    
		  case "-" // Error
		    r = new RedisError( firstLine.MidB( 2 ) )
		    pos = pos + firstLine.LenB + eolLen
		    
		  case "$" // Bulk string
		    dim bytes as integer = firstLine.MidB( 2 ).Val
		    if bytes = -1 then
		      //
		      // Null
		      //
		      r = nil
		      pos = pos + firstLine.LenB + eolLen
		      
		    elseif bytes = 0 then
		      r = ""
		      pos = pos + firstLine.LenB + eolLen + eolLen
		      
		    else
		      r = s.MidB( pos + firstLine.LenB + eolLen, bytes )
		      pos = pos + firstLine.LenB + eolLen + bytes + eolLen
		      
		    end if
		    
		  case "*" // Array
		    dim ub as integer = firstLine.MidB( 2 ).Val - 1
		    pos = pos + firstLine.LenB + eolLen
		    
		    dim arr() as variant
		    redim arr( ub )
		    
		    for i as integer = 0 to ub
		      arr( i ) = InterpretResponse( s, pos )
		    next
		    
		    r = arr
		    
		  end select
		  
		  return r
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Keys(pattern As String = "") As String()
		  if pattern = "" then
		    pattern = "*"
		  end if
		  
		  dim cmd as string = "KEYS " + Escape( pattern )
		  dim arr() as variant = Perform( cmd )
		  
		  dim r() as string
		  redim r( arr.Ubound )
		  for i as integer = 0 to arr.Ubound
		    r( i ) = arr( i ).StringValue
		  next
		  
		  return r
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Perform(cmd As String) As Variant
		  dim h as new SemaphoreHolder( CommandSemaphore )
		  
		  Socket.Write cmd
		  Socket.Write EOL
		  
		  dim r as variant = GetReponse
		  h = nil
		  
		  if r.Type = Variant.TypeObject and r isa RedisError then
		    RaiseException 0, RedisError( r ).Message
		  end if
		  
		  return r
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Ping(msg As String = "") As String
		  if msg = "" then
		    return Perform( "PING" )
		  else
		    dim cmd as string = BuildArray( "PING", msg )
		    return Perform( cmd )
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RaiseException(code As Integer, msg As String)
		  dim err as new RuntimeException
		  err.ErrorNumber = code
		  err.Message = msg
		  raise err
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Rename(oldKey As String, newKey As String, errorIfExists As Boolean = False)
		  dim cmd as string
		  
		  if errorIfExists then
		    
		    cmd = "RENAMENX " + Escape( oldKey ) + " " + Escape( newKey )
		    dim cnt as integer = Perform( cmd ).IntegerValue
		    if cnt = 0 then
		      RaiseException 0, "Key """ + newKey + """ already exists"
		    end if
		    
		  else
		    
		    cmd = "RENAME " + Escape( oldKey ) + " " + Escape( newKey )
		    call Perform( cmd )
		    
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Scan(pattern As String = "") As String()
		  dim parts() as string = array( "0" )
		  if pattern <> "" then
		    parts.Append "MATCH"
		    parts.Append pattern
		  end if
		  parts.Append "COUNT"
		  parts.Append "20"
		  
		  dim r() as string
		  dim cursor as string
		  
		  do
		    dim arr() as variant = Execute( "SCAN", parts )
		    cursor = arr( 0 ).StringValue
		    dim keys() as variant = arr( 1 )
		    for i as integer = 0 to keys.Ubound
		      r.Append keys( i )
		    next
		    parts( 0 ) = cursor
		  loop until cursor = "0"
		  
		  return r
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(key As String, value As String, expireMilliseconds As Integer = 0, mode As SetMode = SetMode.Always) As Boolean
		  dim parts() as string = array( "SET", key, value )
		  
		  if expireMilliseconds > 0 then
		    parts.Append "PX"
		    parts.Append str( expireMilliseconds )
		  end if
		  
		  select case mode
		  case SetMode.IfExists
		    parts.Append "XX"
		  case SetMode.IfNotExists
		    parts.Append "NX"
		  end select
		  
		  dim cmd as string = BuildArray( parts )
		  dim r as variant = Perform( cmd )
		  return not r.IsNull
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetMultiple(ParamArray keyValue() As Pair)
		  SetMultiple keyValue
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetMultiple(keyValue() As Pair)
		  dim parts() as string
		  
		  for i as integer = 0 to keyValue.Ubound
		    dim p as pair = keyValue( i )
		    parts.Append p.Left
		    parts.Append p.Right
		  next
		  
		  call Execute( "MSET", parts )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Socket_DataAvailable(sender As TCPSocket)
		  #pragma unused sender
		  
		  dim t as Thread = CurrentThread
		  if t isa Thread and t.State = Thread.Sleeping then
		    t.Resume
		  end if
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private BugVersion As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private CommandDelete As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private CommandFlushAll As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private CommandFlushDB As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private CommandSemaphore As Semaphore
	#tag EndProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  if zCurrentThreadWR is nil then
			    return nil
			  else
			    return Thread( zCurrentThreadWR.Value )
			  end if
			  
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  if value is nil then
			    zCurrentThreadWR = nil
			  else
			    zCurrentThreadWR = new WeakRef( value )
			  end if
			End Set
		#tag EndSetter
		Private CurrentThread As Thread
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  const kEOL as string = &u0D + &u0A
			  return kEOL
			  
			End Get
		#tag EndGetter
		Private Shared EOL As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  if Socket is nil then
			    return 0
			  else
			    return Socket.LastErrorCode
			  end if
			  
			End Get
		#tag EndGetter
		LastErrorCode As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private MajorVersion As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private MinorVersion As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Socket As TCPSocket
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return zVersion
			  
			End Get
		#tag EndGetter
		Version As String
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Attributes( hidden ) Private zCurrentThreadWR As WeakRef
	#tag EndProperty

	#tag Property, Flags = &h21
		Attributes( hidden ) Private zVersion As String
	#tag EndProperty


	#tag Constant, Name = kConfigRequirePass, Type = String, Dynamic = False, Default = \"requirepass", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kDefaultHost, Type = String, Dynamic = False, Default = \"localhost", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kDefaultPort, Type = Double, Dynamic = False, Default = \"6379", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSectionAll, Type = String, Dynamic = False, Default = \"all", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSectionClients, Type = String, Dynamic = False, Default = \"clients", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSectionCluster, Type = String, Dynamic = False, Default = \"cluster", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSectionCommandStats, Type = String, Dynamic = False, Default = \"commandstats", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSectionCPU, Type = String, Dynamic = False, Default = \"cpu", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSectionDefault, Type = String, Dynamic = False, Default = \"default", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSectionKeyspace, Type = String, Dynamic = False, Default = \"keyspace", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSectionMemory, Type = String, Dynamic = False, Default = \"memory", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSectionPersistence, Type = String, Dynamic = False, Default = \"persistence", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSectionReplication, Type = String, Dynamic = False, Default = \"replication", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSectionServer, Type = String, Dynamic = False, Default = \"server", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSectionStats, Type = String, Dynamic = False, Default = \"stats", Scope = Public
	#tag EndConstant


	#tag Enum, Name = SetMode, Type = Integer, Flags = &h0
		Always
		  IfExists
		IfNotExists
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastErrorCode"
			Group="Behavior"
			Type="Integer"
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
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Version"
			Group="Behavior"
			Type="String"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
