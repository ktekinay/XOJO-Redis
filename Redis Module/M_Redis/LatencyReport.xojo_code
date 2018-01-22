#tag Class
Protected Class LatencyReport
	#tag Method, Flags = &h0
		Sub Constructor()
		  MinimumMs = val( "+INF" )
		  MaximumMs = val( "-INF" )
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		AverageMs As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		MaximumMs As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		MinimumMs As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		Samples As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		TotalSecs As Double
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="AverageMs"
			Group="Behavior"
			Type="Double"
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
			Name="MaximumMs"
			Group="Behavior"
			Type="Double"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MinimumMs"
			Group="Behavior"
			Type="Double"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Samples"
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
		#tag ViewProperty
			Name="TotalSecs"
			Group="Behavior"
			Type="Double"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
