#tag Class
Class RedisControl_MTC
Inherits M_Redis.Redis_MTC
	#tag Method, Flags = &h0
		Function Connect(pw As String="") As Boolean
		  RaiseEvent Connecting
		  
		  dim r as boolean = super.Connect( pw )
		  if r then
		    RaiseEvent Connected
		  end if
		  
		  return r
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  //
		  // Do not call super.Constructor!
		  //
		  
		  Initialize
		  
		  if DefaultAddress <> "" then
		    Address = DefaultAddress
		  end if
		  
		  if DefaultPort > 0 then
		    Port = DefaultPort
		  end if
		  
		  OpenTimer = new Timer
		  AddHandler OpenTimer.Action, WeakAddressOf OpenTimer_Action
		  OpenTimer.Period = 1
		  OpenTimer.Mode = Timer.ModeSingle
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  TeardownOpenTimer
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub OpenTimer_Action(sender As Timer)
		  #pragma unused sender
		  
		  RaiseEvent Opened
		  
		  TeardownOpenTimer
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub TeardownOpenTimer()
		  if OpenTimer isa object then
		    OpenTimer.Mode = Timer.ModeOff
		    RemoveHandler OpenTimer.Action, WeakAddressOf OpenTimer_Action
		    OpenTimer = nil
		  end if
		  
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0, Description = 54686520636F6E6E656374696F6E20746F20612052656469732073657276657220686173206265656E2065737461626C69736865642E
		Event Connected()
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 41626F757420746F20636F6E6E65637420746F2061205265646973205365727665722E20596F752063616E20736574207570204164647265737320616E6420506F7274206865726520696620796F75207072656665722E
		Event Connecting()
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 5468652077696E646F7720686173206F70656E656420616E64207468697320636C61737320686173206265656E20696E697469616C697A65642E205573652074686973206576656E7420746F20736574206164646974696F6E616C2070726F70657274696573206F7220436F6E6E6563742E
		Event Opened()
	#tag EndHook


	#tag Property, Flags = &h0
		DefaultAddress As String = "localhost"
	#tag EndProperty

	#tag Property, Flags = &h0
		DefaultPort As Integer = 6379
	#tag EndProperty

	#tag Property, Flags = &h21
		Private OpenTimer As Timer
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Address"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DefaultAddress"
			Visible=true
			Group="Behavior"
			InitialValue="localhost"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DefaultPort"
			Visible=true
			Group="Behavior"
			InitialValue="6379"
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
			Name="IsConnected"
			Group="Behavior"
			Type="Boolean"
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
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastErrorCode"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LatencyMs"
			Group="Behavior"
			Type="Double"
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
			Name="Port"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RedisVersion"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ResultCount"
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
			Name="TimeoutSecs"
			Group="Behavior"
			InitialValue="30"
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
			Name="TrackLatency"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
