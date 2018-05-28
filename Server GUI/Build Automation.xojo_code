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
					FolderItem = Li4vLi4vU2hhcmVkJTIwUmVzb3VyY2VzL0NvcHklMjBJbnRvJTIwUHJvamVjdHMvcmVkaXMtc2VydmVyLWd1aS5jb25m
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
			End
#tag EndBuildAutomation
