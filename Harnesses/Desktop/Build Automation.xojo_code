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
					Architecture = 0
					Destination = 1
					Subdirectory = 
					FolderItem = Li4vLi4vLi4vU2hhcmVkJTIwUmVzb3VyY2VzL0NvcHklMjBJbnRvJTIwUHJvamVjdHMvcmVkaXMtcG9ydC0zMTk5OS1uby1zYXZlLmNvbmY=
					FolderItem = Li4vLi4vLi4vU2hhcmVkJTIwUmVzb3VyY2VzL0NvcHklMjBJbnRvJTIwUHJvamVjdHMvUmVkaXMlMjBTZXJ2ZXIlMjBNYWMlMjBJbnRlbC8=
					FolderItem = Li4vLi4vLi4vU2hhcmVkJTIwUmVzb3VyY2VzL0NvcHklMjBJbnRvJTIwUHJvamVjdHMvUmVkaXMlMjBTZXJ2ZXIlMjBNYWMlMjBBUk0v
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
				Begin CopyFilesBuildStep CopyRedisServerWin
					AppliesTo = 0
					Architecture = 0
					Destination = 1
					Subdirectory = 
					FolderItem = Li4vLi4vLi4vU2hhcmVkJTIwUmVzb3VyY2VzL0NvcHklMjBJbnRvJTIwUHJvamVjdHMvUmVkaXMlMjBTZXJ2ZXIlMjBXaW5kb3dzLw==
					FolderItem = Li4vLi4vLi4vU2hhcmVkJTIwUmVzb3VyY2VzL0NvcHklMjBJbnRvJTIwUHJvamVjdHMvcmVkaXMtcG9ydC0zMTk5OS1uby1zYXZlLmNvbmY=
				End
			End
#tag EndBuildAutomation
