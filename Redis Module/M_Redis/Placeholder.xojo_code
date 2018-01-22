#tag Class
Private Class Placeholder
	#tag Property, Flags = &h0
		Arr() As Variant
	#tag EndProperty

	#tag Property, Flags = &h0
		ArrayStart As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h0
		EolPos As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		FirstChar As String
	#tag EndProperty

	#tag Property, Flags = &h0
		FirstLine As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Pos As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		R As Variant
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="ArrayStart"
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="EolPos"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FirstChar"
			Group="Behavior"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FirstLine"
			Group="Behavior"
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
			Name="Pos"
			Group="Behavior"
			Type="Integer"
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
