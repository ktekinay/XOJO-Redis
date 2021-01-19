#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  mOptions = SetOptions
		  mOptions.Parse args
		  
		  If mOptions.HelpRequested Then
		    PrintHelp
		    Return 0
		  End If
		  
		  App.RedisAddress = mOptions.StringValue( kOptionAddress, Redis_MTC.kDefaultAddress )
		  App.RedisPort = mOptions.IntegerValue( kOptionPort, Redis_MTC.kDefaultPort )
		  App.RedisPassword = mOptions.StringValue( kOptionPassword, "" )
		  
		  dim local as RedisServer_MTC
		  if mOptions.BooleanValue( kOptionLocalServer, false ) then
		    App.RedisAddress = "localhost"
		    App.RedisPort = mOptions.IntegerValue( kOptionPort, 31999 )
		    
		    local = NewLocalServer
		    local.Port = App.RedisPort
		    local.Start
		    
		    dim targetTicks as integer = Ticks + 60
		    while local.IsRunning and not local.IsReady and Ticks <= targetTicks
		      App.DoEvents
		    wend
		    
		    if not local.IsReady then
		      print "Could not start local server: " + local.LastMessage
		      return 1
		    end if
		  end if
		  
		  // Initialize Groups
		  Print "Initializing Test Groups..."
		  mController = New ConsoleTestController
		  mController.LoadTestGroups
		  
		  // Filter Tests
		  FilterTests
		  
		  // Run Tests
		  Print "Running Tests..."
		  mController.Start
		  While mController.IsRunning
		    App.DoEvents
		  Wend
		  
		  if local isa object then
		    local.Stop
		    local = nil
		  end if
		  
		  // Output Results
		  Print "Saving Results..."
		  
		  Dim outputFile As FolderItem
		  outputFile = OutputResults
		  
		  PrintSummary(StdOut, mController)
		  
		  #if TargetWindows then
		    print "Press any key to continue..."
		    call Input
		  #endif
		  
		End Function
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub FilterTests()
		  // Filter the tests based on the Include and Exclude options
		  
		  Dim includeOption As Option = mOptions.OptionValue(kOptionInclude)
		  Dim excludeOption As Option = mOptions.OptionValue(kOptionExclude)
		  
		  If includeOption.WasSet Or excludeOption.WasSet Then
		    Print "Filtering Tests..."
		  Else
		    Return
		  End If
		  
		  Dim includes() As String
		  If Not includeOption.Value.IsNull Then
		    Dim v() As Variant = includeOption.Value
		    For Each pattern As String In v
		      includes.Append pattern
		    Next
		  End If
		  
		  Dim excludes() As String
		  If not excludeOption.Value.IsNull Then
		    Dim v() As Variant = excludeOption.Value
		    For Each pattern As String In v
		      excludes.Append pattern
		    Next
		  End If
		  
		  mController.FilterTests(includes, excludes)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NewLocalServer() As RedisServer_MTC
		  dim serverFile as FolderItem 
		  #if TargetMacOS then
		    
		    dim folderName as string  = "Redis Server Mac "
		    if IsAppleARM then
		      folderName = folderName + "ARM"
		    else
		      folderName = folderName + "Intel"
		    end if
		    
		    serverFile = App.ResourcesFolder.Child( folderName ).Child( "redis-server" )
		  #else
		    serverFile = App.ResourcesFolder.Child( "Redis Server Windows" ).Child( "redis-server.exe" )
		  #endif
		  dim configFile as FolderItem = App.ResourcesFolder.Child( "redis-port-31999-no-save.conf" )
		  
		  dim server as new RedisServer_MTC
		  server.RedisServerFile = serverFile
		  server.ConfigFile = configFile
		  
		  return server
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function OutputResults() As FolderItem
		  Const kIndent = "   "
		  Const kFailIndent = " * "
		  
		  Dim outputFile As FolderItem
		  If mOptions.Extra.Ubound = -1 Then
		    outputFile = GetFolderItem(kDefaultExportFileName)
		  Else
		    outputFile = GetFolderItem(mOptions.Extra(0), FolderItem.PathTypeNative)
		    If outputFile.Directory Then
		      outputFile = outputFile.Child(kDefaultExportFileName)
		    End If
		  End If
		  
		  Dim output As TextOutputStream = TextOutputStream.Create(outputFile)
		  
		  PrintSummary(output, mController)
		  
		  #If DebugBuild
		    Dim debugOutput As String
		  #Endif
		  
		  For Each tg As TestGroup In mController.TestGroups
		    output.WriteLine("")
		    output.WriteLine(tg.Name)
		    #If DebugBuild
		      debugOutput = debugOutput + EndOfLine + tg.Name + EndOfLine
		    #Endif
		    
		    For Each tr As TestResult In tg.Results
		      Dim useIndent As String = If(tr.Result = tr.Failed, kFailIndent, kIndent)
		      Dim outLine As String = useIndent + tr.TestName + ": " + tr.Result + " (" + Format(tr.Duration, "#,###.0000000") + "s)"
		      output.WriteLine(outLine)
		      #If DebugBuild
		        debugOutput = debugOutput + outLine + EndOfLine
		      #Endif
		      
		      Dim msg As String = tr.Message
		      If msg <> "" Then
		        msg = ReplaceLineEndings(msg, EndOfLine)
		        Dim msgs() As String = msg.Split(EndOfLine)
		        
		        For i As Integer = 0 To msgs.Ubound
		          msg = msgs(i)
		          outLine  = kIndent + kIndent + msg
		          output.WriteLine(outLine)
		          #If DebugBuild
		            debugOutput = debugOutput + outLine + EndOfLine
		          #Endif
		        Next i
		      End If
		    Next
		  Next
		  
		  output.Close
		  
		  Return outputFile
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PrintHelp()
		  Print ""
		  Print "Usage: " + mOptions.AppName + " [params] [/path/to/export/file]"
		  Print ""
		  mOptions.ShowHelp
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PrintSummary(output As Writeable, controller As TestController)
		  Dim now As New Date
		  
		  Dim allTestCount As Integer = controller.AllTestCount
		  Dim runTestCount As Integer = controller.RunTestCount
		  
		  WriteLine(output, "Start: " + now.ShortDate + " " + now.ShortTime)
		  WriteLine(output, "Duration: " + Format(controller.Duration, "#,###.0000000") + "s")
		  WriteLine(output, "Groups: " + Format(controller.RunGroupCount, "#,0"))
		  WriteLine(output, "Total: " + Str(runTestCount) + If(allTestCount <> runTestCount, " of " + Str(allTestCount), "") + " tests were run")
		  WriteLine(output, "Passed: " + Str(controller.PassedCount) + _
		  If(runTestCount = 0, "", " (" + Format((controller.PassedCount / runTestCount) * 100, "##.00") + "%)"))
		  WriteLine(output, "Failed: " + Str(controller.FailedCount) + _
		  If(runTestCount = 0, "", " (" + Format((controller.FailedCount / runTestCount) * 100, "##.00") + "%)"))
		  WriteLine(output, "Skipped: " + Str(controller.SkippedCount))
		  WriteLine(output, "Not Implemented: " + Str(controller.NotImplementedCount))
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SetOptions() As OptionParser
		  Dim parser As New OptionParser
		  
		  Dim o As Option
		  
		  o = New Option("i", kOptionInclude, "Include a Group[.Method] (* is wildcard)", Option.OptionType.String)
		  o.IsArray = True
		  parser.AddOption o
		  
		  o = New Option("x", kOptionExclude, "Exclude a Group[.Method] (* is wildcard)", Option.OptionType.String)
		  o.IsArray = True
		  parser.AddOption o
		  
		  parser.AddOption new Option( "a", kOptionAddress, "Redis server address", Option.OptionType.String )
		  parser.AddOption new Option( "p", kOptionPort, "Redis server port", Option.OptionType.Integer )
		  parser.AddOption new Option( "", kOptionPassword, "Redis server password", Option.OptionType.String )
		  parser.AddOption new Option( "l", kOptionLocalServer, _
		  "Start a local server on the given port (forces address to `localhost')", Option.OptionType.Boolean )
		  
		  parser.AdditionalHelpNotes = "If an export path is not specified, a default file named `" + kDefaultExportFileName + _
		  "' will be created next to the app. If the path is a directory, a file of that name will be created within it."
		  
		  Return parser
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteLine(output As Writeable, s As String)
		  output.Write s
		  output.Write EndOfLine
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		CommandDict As Dictionary
	#tag EndProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  #if not TargetMacOS then
			    
			    return false
			    
			  #else
			    
			    static isComputed as boolean
			    static isARM as boolean
			    
			    if not isComputed then
			      dim sh as new Shell
			      sh.Execute "/usr/sbin/sysctl -a | grep 'brand_string'"
			      
			      if sh.ErrorCode <> 0 then
			        dim err as new RuntimeException
			        err.Message = "Could not run sysctl"
			        err.ErrorNumber = sh.ErrorCode
			        raise err
			      end if
			      
			      dim result as string = sh.Result.DefineEncoding( Encodings.UTF8 )
			      isARM = result.InStr( "Apple" ) <> 0
			      
			      isComputed = true
			    end if
			    
			    return isARM
			  #endif
			  
			End Get
		#tag EndGetter
		Private IsAppleARM As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mController As TestController
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOptions As OptionParser
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

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #if TargetMacOS then
			    
			    dim contents as FolderItem = App.ExecutableFile.Parent
			    return contents.Child( "Resources" )
			    
			  #else
			    
			    dim name as string = App.ExecutableFile.Name
			    if name.Right( 4 ) = ".exe" then
			      name = name.Left( name.Len - 4 )
			    end if
			    
			    dim parent as FolderItem = App.ExecutableFile.Parent
			    dim resourcesName as string = name + " Resources"
			    dim resourcesFolder as FolderItem = parent.Child( resourcesName )
			    return resourcesFolder
			    
			  #endif
			End Get
		#tag EndGetter
		ResourcesFolder As FolderItem
	#tag EndComputedProperty


	#tag Constant, Name = kDefaultExportFileName, Type = String, Dynamic = False, Default = \"XojoUnitResults.txt", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOptionAddress, Type = String, Dynamic = False, Default = \"address", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOptionExclude, Type = String, Dynamic = False, Default = \"exclude", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOptionInclude, Type = String, Dynamic = False, Default = \"include", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOptionLocalServer, Type = String, Dynamic = False, Default = \"local-server", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOptionPassword, Type = String, Dynamic = False, Default = \"password", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOptionPort, Type = String, Dynamic = False, Default = \"port", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="RedisAddress"
			Visible=false
			Group="Behavior"
			InitialValue="localhost"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RedisPassword"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RedisPort"
			Visible=false
			Group="Behavior"
			InitialValue="6379"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
