#tag BuildAutomation
			Begin BuildStepList Linux
				Begin BuildProjectStep Build
				End
			End
			Begin BuildStepList Mac OS X
				Begin BuildProjectStep Build
				End
				Begin CopyFilesBuildStep CopyRedisServerMac
					AppliesTo = 0
					Destination = 1
					Subdirectory = 
					FolderItem = Li4vLi4vU2hhcmVkJTIwUmVzb3VyY2VzL0NvcHklMjBJbnRvJTIwUHJvamVjdHMvUmVkaXMlMjBTZXJ2ZXIlMjBNYWMv
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
				Begin CopyFilesBuildStep CopyRedisServerWindows
					AppliesTo = 0
					Destination = 1
					Subdirectory = 
					FolderItem = Li4vLi4vU2hhcmVkJTIwUmVzb3VyY2VzL0NvcHklMjBJbnRvJTIwUHJvamVjdHMvUmVkaXMlMjBTZXJ2ZXIlMjBXaW5kb3dzLw==
				End
			End
#tag EndBuildAutomation
