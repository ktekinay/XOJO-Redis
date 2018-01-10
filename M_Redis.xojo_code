#tag Module
Protected Module M_Redis
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
		Protected Function VariantToStringArray(varr() As Variant) As String()
		  dim arr() as string
		  redim arr( varr.Ubound )
		  for i as integer = 0 to varr.Ubound
		    arr( i ) = varr( i ).StringValue
		  next
		  return arr
		End Function
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
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
	#tag EndViewBehavior
End Module
#tag EndModule
