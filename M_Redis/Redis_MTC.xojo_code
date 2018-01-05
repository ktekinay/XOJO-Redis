#tag Class
Class Redis_MTC
	#tag Method, Flags = &h0
		Function Append(key As String, value As String) As Integer
		  dim v as variant = Execute( "APPEND", key, value )
		  
		  if zIsPipeline then
		    return 0
		  else
		    return v.IntegerValue
		  end if
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Auth(pw As String)
		  call Execute( "AUTH", pw )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BitAnd(destKey As String, key1 As String, key2 As String, ParamArray moreKeys() As String) As Integer
		  dim params() as string = array( "AND", destKey, key1, key2 )
		  for i as integer = 0 to moreKeys.Ubound
		    params.Append moreKeys( i )
		  next
		  
		  dim v as variant = Execute( "BITOP", params )
		  
		  if zIsPipeline then
		    return 0
		  else
		    return v.IntegerValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BitCount(key As String) As Integer
		  dim v as variant = Execute( "BITCOUNT", key )
		  
		  if zIsPipeline then
		    return 0
		  else
		    return v.IntegerValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BitCount(key As String, startB As Integer, endB As Integer) As Integer
		  dim v as variant = Execute( "BITCOUNT", key, str( startB ), str( endB ) )
		  
		  if zIsPipeline then
		    return 0
		  else
		    return v.IntegerValue
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 5479706520697320696E2074686520666F726D2075362C20693136
		Function BitFieldGet(key As String, type As String, offset As Integer, isByteOffset As Boolean = False) As Int64
		  dim offsetString as string = if( isByteOffset, "#", "" ) + str( offset )
		  dim v as variant = Execute( "BITFIELD", key, "GET", type, offsetString )
		  
		  if zIsPipeline then
		    return 0
		  else
		    dim r() as variant = v
		    return r( 0 ).Int64Value
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BitFieldIncrementBy(key As String, type As String, offset As Integer, value As Int64, isByteOffset As Boolean = False, overflow As Overflows = Overflows.Wrap) As Int64
		  dim offsetString as string = if( isByteOffset, "#", "" ) + str( offset )
		  
		  dim params() as string = array( key )
		  if overflow <> Overflows.Wrap then
		    params.Append "OVERFLOW"
		    select case overflow
		    case Overflows.Fail
		      params.Append "FAIL"
		    case Overflows.Sat
		      params.Append "SAT"
		    end select
		  end if
		  
		  params.Append "INCRBY"
		  params.Append type
		  params.Append offsetString
		  params.Append str( value )
		  
		  dim v as variant = Execute( "BITFIELD", params )
		  
		  if zIsPipeline then
		    return 0
		  else
		    dim r() as variant = v
		    return r( 0 ).Int64Value
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BitFieldSet(key As String, type As String, offset As Integer, value As Int64, isByteOffset As Boolean = False) As Int64
		  dim offsetString as string = if( isByteOffset, "#", "" ) + str( offset )
		  dim v as variant = Execute( "BITFIELD", key, "SET", type, offsetString, str( value ) )
		  
		  if zIsPipeline then
		    return 0
		  else
		    dim r() as variant = v
		    return r( 0 ).Int64Value
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BitNot(destKey As String, key As String) As Integer
		  dim v as variant = Execute( "BITOP", "NOT", destKey, key )
		  
		  if zIsPipeline then
		    return 0
		  else
		    return v.IntegerValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BitOr(destKey As String, key1 As String, key2 As String, ParamArray moreKeys() As String) As Integer
		  dim params() as string = array( "OR", destKey, key1, key2 )
		  for i as integer = 0 to moreKeys.Ubound
		    params.Append moreKeys( i )
		  next
		  
		  dim v as variant = Execute( "BITOP", params )
		  
		  if zIsPipeline then
		    return 0
		  else
		    return v.IntegerValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BitPos(key As String, value As Integer, startByteB As Integer = 0, endByteB As Integer = -1) As Integer
		  dim params() as string = array( key, str( value ) )
		  if startByteB > 0 or endByteB > -1 then
		    params.Append str( startByteB )
		    if endByteB > -1 then
		      params.Append str( endByteB )
		    end if
		  end if
		  
		  dim v as variant = Execute( "BITPOS", params )
		  
		  if zIsPipeline then
		    return 0
		  else
		    return v.IntegerValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BitXor(destKey As String, key1 As String, key2 As String, ParamArray moreKeys() As String) As Integer
		  dim params() as string = array( "XOR", destKey, key1, key2 )
		  for i as integer = 0 to moreKeys.Ubound
		    params.Append moreKeys( i )
		  next
		  
		  dim v as variant = Execute( "BITOP", params )
		  
		  if zIsPipeline then
		    return 0
		  else
		    return v.IntegerValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ConfigGet(pattern As String = "*") As Dictionary
		  if pattern = "" then
		    pattern = "*"
		  end if
		  
		  dim v as variant = Execute( "CONFIG", "GET", pattern )
		  
		  if zIsPipeline then
		    
		    return nil
		    
		  else
		    
		    dim arr() as variant = v
		    dim r as new Dictionary
		    for i as integer = 0 to arr.Ubound step 2
		      r.Value( arr( i ).StringValue ) = arr( i + 1 ).StringValue
		    next
		    
		    return r
		    
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ConfigSet(parameter As String, value As String)
		  call Execute( "CONFIG", "SET", parameter, value )
		  
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
		Function Decrement(key As String) As Integer
		  dim v as variant = Execute( "DECR", key )
		  
		  if zIsPipeline then
		    return 0
		  else
		    return v.IntegerValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DecrementBy(key As String, value As Integer) As Integer
		  dim v as variant = Execute( "DECRBY", key, str( value ) )
		  
		  if zIsPipeline then
		    return 0
		  else
		    return v.IntegerValue
		  end if
		  
		End Function
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
		    dim v as variant = Execute( CommandDelete, keys )
		    if zIsPipeline then
		      return -3
		    else
		      return v.IntegerValue
		    end if
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Delete(key As String, silent As Boolean = False)
		  dim v as variant = Execute( CommandDelete, key )
		  
		  if not silent and not zIsPipeline and v.IntegerValue = 0 then
		    raise new KeyNotFoundException
		  end if
		  
		  
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
		  static eol as string = self.EOL
		  
		  dim h as new SemaphoreHolder( CommandSemaphore )
		  
		  dim cmd as string = command
		  
		  if IsFlushingPipeline then
		    //
		    // cmd is good
		    //
		    #if DebugBuild then
		      cmd = cmd // A place to break
		    #endif
		    
		  elseif parameters is nil or parameters.Ubound = -1 then
		    //
		    // cmd is good
		    //
		    #if DebugBuild then
		      cmd = cmd // A place to break
		    #endif
		    
		    if zIsPipeline then
		      Pipeline.Append cmd
		    end if
		    
		  else
		    
		    dim arrCount as integer = parameters.Ubound + 2
		    dim raw() as string
		    if zIsPipeline then
		      raw = Pipeline
		    end if
		    
		    raw.Append "*" + str( arrCount )
		    
		    raw.Append "$" + str( command.LenB )
		    raw.Append command
		    
		    for i as integer = 0 to parameters.Ubound
		      dim p as string = parameters( i )
		      raw.Append "$" + str( p.LenB )
		      raw.Append p
		      
		    next
		    
		    if not zIsPipeline then
		      cmd = join( raw, eol )
		    end if
		  end if
		  
		  if zIsPipeline and not IsFlushingPipeline then
		    
		    return true
		    
		  else
		    
		    zLastCommand = cmd
		    
		    Socket.Write cmd
		    Socket.Write eol
		    Socket.Flush
		    
		    dim r as variant = GetReponse
		    h = nil
		    
		    if r.Type = Variant.TypeObject and r isa RedisError then
		      RaiseException 0, RedisError( r ).Message
		    end if
		    
		    return r
		    
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Execute(command As String, ParamArray parameters() As String) As Variant
		  return Execute( command, parameters )
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Exists(key As String) As Boolean
		  dim v as variant = Execute( "EXISTS", key )
		  
		  if zIsPipeline then
		    return true
		  else
		    return v.IntegerValue <> 0
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Exists(key1 As String, key2 As String, ParamArray moreKeys() As String) As Integer
		  dim parts() as string = array( key1, key2 )
		  for each key as string in moreKeys
		    parts.Append key
		  next
		  
		  dim v as variant = Execute( "EXISTS", parts )
		  
		  if zIsPipeline then
		    return 0
		  else
		    return v.IntegerValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Expire(key As String, milliseconds As Integer)
		  dim r as variant = Execute( "PEXPIRE", key, str( milliseconds ) )
		  if r.IntegerValue = 0 then
		    raise new KeyNotFoundException
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ExpireAt(key As String, target As Date)
		  static baseDate as Date
		  if baseDate is nil then
		    baseDate = new Date( 1970, 1, 1 )
		    baseDate.TotalSeconds = baseDate.TotalSeconds + ( baseDate.GMTOffset * 60.0 * 60.0 )
		    baseDate.GMTOffset = 0
		  end if
		  
		  dim unixTimestamp as Int64 = target.TotalSeconds - baseDate.TotalSeconds - ( target.GMTOffset * 60.0 * 60.0 )
		  
		  dim r as variant = Execute( "EXPIREAT", key, str( unixTimestamp ) )
		  if r.IntegerValue = 0 then
		    raise new KeyNotFoundException
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FlushAll()
		  if CommandFlushAll = "" then
		    CommandFlushAll = "FLUSHALL" + if( MajorVersion >= 4, " ASYNC", "" )
		  end if
		  call Execute( CommandFlushAll )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FlushDB()
		  if CommandFlushDB = "" then
		    CommandFlushDB = "FLUSHDB" + if( MajorVersion >= 4, " ASYNC", "" )
		  end if
		  call Execute( CommandFlushDB, nil )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FlushPipeline(stopPipeline As Boolean = True) As Variant()
		  dim arr() as variant
		  
		  if Pipeline.Ubound <> -1 then
		    IsFlushingPipeline = true
		    arr = Execute( join( Pipeline, EOL ), nil )
		    IsFlushingPipeline = false
		    redim Pipeline( -1 )
		  end if
		  
		  zIsPipeline = not stopPipeline
		  
		  return arr
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(key As String) As String
		  dim v as variant = Execute( "GET", key )
		  
		  if zIsPipeline then
		    return ""
		    
		  elseif v.IsNull then
		    raise new KeyNotFoundException
		    
		  else
		    return v.StringValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetBit(key As String, startB As Integer) As Integer
		  dim v as variant = Execute( "GETBIT", key, str( startB ) )
		  
		  if zIsPipeline then
		    return 0
		  else
		    return v.IntegerValue
		  end if
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetMultiple(ParamArray keys() As String) As Variant()
		  return GetMultiple( keys )
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetMultiple(keys() As String) As Variant()
		  dim r as variant = Execute( "MGET", keys )
		  if r.IsArray then
		    return r
		  else
		    dim arr() as variant
		    arr.Append r
		    return arr
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetRange(key As String, startB As Integer, endB As Integer) As String
		  dim v as variant = Execute( "GETRANGE", key, str( startB ), str( endB ) )
		  
		  if zIsPipeline then
		    return ""
		  else
		    return v.StringValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetReponse() As Variant
		  const kDebug as boolean = DebugBuild and false
		  
		  #if DebugBuild then
		    const kWaitTicks as integer = 60 * 60
		  #else
		    const kWaitTicks as integer = 60 \ 2
		  #endif
		  
		  #if kDebug then
		    dim sw as new Stopwatch_MTC
		    sw.Start
		  #endif
		  
		  dim raw as string
		  
		  dim targetTicks as integer = Ticks + kWaitTicks
		  
		  Socket.Poll
		  if Socket.BytesAvailable = 0 then
		    do
		      for i as integer =  1 to 100
		        Socket.Poll
		        if Socket.BytesAvailable <> 0 then
		          exit do
		        end if
		      next
		    loop until Ticks > targetTicks
		  end if
		  
		  raw = Socket.ReadAll( Encodings.UTF8 )
		  
		  #if kDebug then
		    sw.Stop
		    dim logMsg as string = CurrentMethodName + ": Response took " + format( sw.ElapsedMicroseconds, "#,0" ) + " microsecs"
		    if App.CurrentThread isa object then
		      logMsg = logMsg + ", thread id " + str( App.CurrentThread.ThreadID )
		    end if
		    System.DebugLog logMsg
		  #endif
		  
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
		Function GetSet(key As String, value As String) As String
		  dim v as variant = Execute( "GETSET", key, value )
		  
		  if zIsPipeline then
		    return ""
		  else
		    return v.StringValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Increment(key As String) As Integer
		  dim v as variant = Execute( "INCR", key )
		  
		  if zIsPipeline then
		    return 0
		  else
		    return v.IntegerValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IncrementBy(key As String, value As Integer) As Integer
		  dim v as variant = Execute( "INCRBY", key, str( value ) )
		  
		  if zIsPipeline then
		    return 0
		  else
		    return v.IntegerValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IncrementByFloat(key As String, value As Double) As Double
		  dim v as variant = Execute( "INCRBYFLOAT", key, str( value, "-0.0#############" ) )
		  
		  if zIsPipeline then
		    return 0.0
		  else
		    return v.DoubleValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Info(section As String = "") As String
		  dim v as variant
		  if section = "" then
		    v = Execute( "INFO", nil )
		  else
		    v = Execute( "INFO", section )
		  end if
		  
		  if zIsPipeline then
		    return ""
		  else
		    return v.StringValue
		  end if
		  
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
		Private Function InterpretResponse(s As String, ByRef pos As Integer, isSubprocess As Boolean = False) As Variant
		  static eol as string = self.EOL
		  static eolLen as integer = eol.LenB
		  
		  dim rArr() as variant
		  dim r as variant
		  
		  if pos < 2 then
		    pos = 1
		  end if
		  
		  dim sLen as integer = s.LenB
		  
		  dim useArr as boolean = IsFlushingPipeline and not isSubprocess
		  
		  do
		    
		    dim firstLine as string
		    dim eolPos as integer = s.InStrB( pos, eol )
		    if eolPos = 0 then
		      eolPos = s.LenB + 1
		    end if
		    firstLine = s.MidB( pos, eolPos - pos )
		    
		    if firstLine = "+OK" then
		      r = true
		      pos = pos + firstLine.LenB + eolLen
		      
		    else
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
		          arr( i ) = InterpretResponse( s, pos, true )
		        next
		        
		        r = arr
		        
		      end select
		      
		    end if
		    
		    if useArr then
		      rArr.Append r
		    else
		      exit
		    end if
		    
		  loop until pos > sLen
		  
		  if useArr then
		    return rArr
		  else
		    return r
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Keys(pattern As String = "") As String()
		  if pattern = "" then
		    pattern = "*"
		  end if
		  
		  dim v as variant = Execute( "KEYS", pattern )
		  dim r() as string
		  
		  if not zIsPipeline then
		    dim arr() as variant = v
		    redim r( arr.Ubound )
		    for i as integer = 0 to arr.Ubound
		      r( i ) = arr( i ).StringValue
		    next
		  end if
		  
		  return r
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Persist(key As String)
		  call Execute( "PERSIST", key )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Ping(msg As String = "") As String
		  dim v as variant
		  
		  if msg = "" then
		    v = Execute( "PING", nil )
		  else
		    v = Execute( "PING", msg )
		  end if
		  
		  if zIsPipeline then
		    return ""
		  else
		    return v.StringValue
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
		  if errorIfExists then
		    
		    dim v as variant = Execute( "RENAMENX", oldKey, newKey )
		    if not zIsPipeline and v.IntegerValue = 0 then
		      RaiseException 0, "Key """ + newKey + """ already exists"
		    end if
		    
		  else
		    
		    call Execute( "RENAME", oldKey, newKey )
		    
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Scan(pattern As String = "") As String()
		  if zIsPipeline then
		    RaiseException 0, "SCAN is not available within a Pipeline"
		  end if
		  
		  dim parts( 0 ) as string
		  if pattern <> "" then
		    parts.Append "MATCH"
		    parts.Append pattern
		  end if
		  parts.Append "COUNT"
		  parts.Append "20"
		  
		  dim r() as string
		  dim cursor as string = "0"
		  
		  do
		    parts( 0 ) = cursor
		    dim arr() as variant = Execute( "SCAN", parts )
		    cursor = arr( 0 ).StringValue
		    dim keys() as variant = arr( 1 )
		    for i as integer = 0 to keys.Ubound
		      r.Append keys( i )
		    next
		  loop until cursor = "0"
		  
		  return r
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Set(key As String, value As String, expireMilliseconds As Integer = 0, mode As SetMode = SetMode.Always) As Boolean
		  dim parts() as string = array( key, value )
		  
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
		  
		  dim r as variant = Execute( "SET", parts )
		  return not r.IsNull
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetBit(key As String, startB As Integer, value As Integer) As Integer
		  dim v as variant = Execute( "SETBIT", key, str( startB ), str( value ) )
		  if zIsPipeline then
		    return -3
		  else
		    return v.IntegerValue
		  end if
		  
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

	#tag Method, Flags = &h0
		Function SetMultipleIfNoneExist(keyValue() As Pair) As Boolean
		  dim parts() as string
		  
		  for i as integer = 0 to keyValue.Ubound
		    dim p as pair = keyValue( i )
		    parts.Append p.Left
		    parts.Append p.Right
		  next
		  
		  dim v as variant = Execute( "MSETNX", parts )
		  
		  if zIsPipeline then
		    return true
		  else
		    return v.IntegerValue <> 0
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetMultipleIfNoneExist(ParamArray keyValue() As Pair) As Boolean
		  return SetMultipleIfNoneExist( keyValue )
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetRange(key As String, startB As Integer, value As String) As Integer
		  dim v as variant = Execute( "SETRANGE", key, str( startB ), value )
		  
		  if zIsPipeline then
		    return 0
		  else
		    return v.IntegerValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StartPipeline()
		  zIsPipeline = true
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StrLen(key As String) As Integer
		  dim v as variant = Execute( "STRLEN", key )
		  
		  if zIsPipeline then
		    return -3
		  else
		    return v.IntegerValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TimeToLiveMs(key As String) As Integer
		  dim v as variant = Execute( "PTTL", key )
		  
		  if zIsPipeline then
		    
		    return -3
		    
		  else
		    dim r as integer = v.IntegerValue
		    
		    if r = -2 then
		      raise new KeyNotFoundException
		    end if
		    
		    return r
		    
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Touch(keys() As String) As Integer
		  dim v as variant = Execute( "TOUCH", keys )
		  
		  if zIsPipeline then
		    return -3
		  else
		    return v.IntegerValue
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Touch(ParamArray keys() As String) As Integer
		  return Touch( keys )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type(key As String) As String
		  dim v as variant = Execute( "TYPE", key )
		  
		  if zIsPipeline then
		    return ""
		  else
		    dim t as string = v.StringValue
		    if t = "none" then
		      raise new KeyNotFoundException
		    end if
		    return t
		  end if
		End Function
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
			  const kEOL as string = &u0D + &u0A
			  return kEOL
			  
			End Get
		#tag EndGetter
		Private Shared EOL As String
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private IsFlushingPipeline As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return zIsPipeline
			  
			End Get
		#tag EndGetter
		IsPipeline As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return zLastCommand
			  
			End Get
		#tag EndGetter
		LastCommand As String
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
		Private Pipeline() As String
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
		Attributes( hidden ) Private zIsPipeline As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Attributes( hidden ) Private zLastCommand As String
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

	#tag Constant, Name = kTypeInt16, Type = String, Dynamic = False, Default = \"i16", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kTypeInt32, Type = String, Dynamic = False, Default = \"i32", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kTypeInt64, Type = String, Dynamic = False, Default = \"i64", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kTypeInt8, Type = String, Dynamic = False, Default = \"i8", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kTypeUInt16, Type = String, Dynamic = False, Default = \"u16", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kTypeUInt32, Type = String, Dynamic = False, Default = \"u32", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kTypeUint63, Type = String, Dynamic = False, Default = \"u63", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kTypeUInt8, Type = String, Dynamic = False, Default = \"u8", Scope = Public
	#tag EndConstant


	#tag Enum, Name = Overflows, Type = Integer, Flags = &h0
		Wrap
		  Sat
		Fail
	#tag EndEnum

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
			Name="IsPipeline"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastCommand"
			Group="Behavior"
			Type="String"
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
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
