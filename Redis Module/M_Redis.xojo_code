#tag Module
Protected Module M_Redis
	#tag Method, Flags = &h1
		Protected Function CommandArrayToDictionary(varr() As Variant) As Dictionary
		  if varr() is nil then
		    return nil
		  end if
		  
		  dim d as new Dictionary
		  
		  for outerIndex as integer = 0 to varr.Ubound
		    
		    if varr( outerIndex ).IsArray then
		      dim element() as variant = varr( outerIndex )
		      dim spec as new M_Redis.CommandSpec( element )
		      d.Value( spec.Name ) = spec
		    end if
		    
		  next
		  
		  return d
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HashArrayToDictionary(varr() As Variant, useDict As Dictionary = Nil) As Dictionary
		  dim d as Dictionary = useDict
		  if d is nil then
		    d = new Dictionary
		  end if
		  
		  for i as integer = 0 to varr.Ubound step 2
		    d.Value( varr( i ) ) = varr( i + 1 )
		  next
		  
		  return d
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function InfoStringToDictionary(s As String) As Dictionary
		  //
		  // Will either return a Dictionary or a Dictionary of Dictionaries if there
		  // are multiple sections
		  //
		  s = ReplaceLineEndings( s, EndOfLine.UNIX )
		  dim lines() as string = s.SplitB( EndOfLine.UNIX )
		  
		  dim masterDictionary as Dictionary
		  dim sectionDictionary as Dictionary
		  dim currentSection as string
		  
		  for i as integer = 0 to lines.Ubound
		    dim thisLine as string = lines( i ).Trim
		    
		    if thisLine.LeftB( 1 ) = "#" then
		      if i <> 0 and masterDictionary is nil then
		        //
		        // This is not the first section
		        //
		        masterDictionary = new Dictionary
		        masterDictionary.Value( currentSection ) = sectionDictionary
		      end if
		      
		      currentSection = thisLine.MidB( 2 ).Trim
		      sectionDictionary = new Dictionary
		      
		      if masterDictionary isa object then
		        masterDictionary.Value( currentSection ) = sectionDictionary
		      end if
		      
		    elseif thisLine <> "" then
		      dim field as string = thisLine.NthFieldB( ":", 1 )
		      dim value as string = thisLine.MidB( field.LenB + 2 )
		      sectionDictionary.Value( field ) = value
		    end if
		  next
		  
		  if masterDictionary isa object then
		    return masterDictionary
		  else
		    return sectionDictionary
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ShellPathOf(f As FolderItem) As String
		  if f is nil then
		    return ""
		  end if
		  
		  #if TargetWindows then
		    dim path as string = f.NativePath
		    if path.Right( 1 ) = "\" then
		      path = path.Left( path.Len - 1 )
		    end if
		    return """" + path + """"
		  #else
		    return f.ShellPath
		  #endif
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function VariantToSortedSetItemArray(varr() As Variant) As M_Redis.SortedSetItem()
		  dim r() as M_Redis.SortedSetItem
		  
		  for i as integer = 0 to varr.Ubound step 2
		    dim member as string = varr( i ).StringValue
		    dim score as double = varr( i + 1 ).DoubleValue
		    dim item as new M_Redis.SortedSetItem( score, member )
		    r.Append item
		  next
		  
		  return r
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function VariantToStringArray(varr() As Variant) As String()
		  dim arr() as string
		  redim arr( varr.Ubound )
		  for i as integer = 0 to varr.Ubound
		    arr( i ) = varr( i ).StringValue
		  next
		  return arr
		End Function
	#tag EndMethod


	#tag Note, Name = About Redis_MTC vs. RedisControl_MTC
		Redis_MTC is the main class and should be used in most cases. It will
		automatically connect on instantiation and raise an Exception if it can't.
		
		RedisControl_MTC is for use on windows and has additional events for that purpose.
		It will not automatically connect and will let you handle a TCPSocket error 
		gracefully without raising an exception.
		
		RedisControl_MTC can be used in code directly too if you prefer not to
		automatically connect.
	#tag EndNote

	#tag Note, Name = Documentation
		See the Redis documentation at
		
		https://redis.io
		
		See the README at
		
		https://github.com/ktekinay/XOJO-Redis
		
	#tag EndNote

	#tag Note, Name = License
		See the license at 
		
		https://github.com/ktekinay/XOJO-Redis
	#tag EndNote


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
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
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
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
End Module
#tag EndModule
