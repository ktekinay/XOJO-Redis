#tag Class
Protected Class CommandSpec
	#tag Method, Flags = &h0
		Sub Constructor(element() As Variant = Nil)
		  if not ( element is nil ) then
		    //
		    // Expects a 5 element array with the values we need
		    //
		    Name = element( 0 )
		    Arity = element( 1 ).IntegerValue
		    
		    dim flags() as variant = element( 2 )
		    for flagIndex as integer = 0 to flags.Ubound
		      self.Flags.Append flags( flagIndex )
		    next
		    
		    FirstKeyIndex = element( 3 )
		    LastKeyIndex = element( 4 )
		    KeyStepCount = element( 5)
		    
		  end if
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Arity As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		FirstKeyIndex As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Flags() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		KeyStepCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		LastKeyIndex As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Arity"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FirstKeyIndex"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="KeyStepCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastKeyIndex"
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
	#tag EndViewBehavior
End Class
#tag EndClass
