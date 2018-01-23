#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Open()
		  XojoUnitTestWindow.Show
		  WndRedisSettings.Show
		  WndRedisSettings.Left = XojoUnitTestWindow.Left + XojoUnitTestWindow.Width
		  XojoUnitTestWindow.Show
		  
		End Sub
	#tag EndEvent


	#tag Property, Flags = &h0
		CommandDict As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		RedisAddress As String = "localhost"
	#tag EndProperty

	#tag Property, Flags = &h0
		RedisPassword As String
	#tag EndProperty

	#tag Property, Flags = &h0
		RedisPort As Integer = 6379
	#tag EndProperty


	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="RedisAddress"
			Group="Behavior"
			InitialValue="localhost"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RedisPassword"
			Group="Behavior"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RedisPort"
			Group="Behavior"
			InitialValue="6379"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
