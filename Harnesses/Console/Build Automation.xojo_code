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
					FolderItem = Li4vLi4vQ29weSUyMEludG8lMjBQcm9qZWN0cy9yZWRpcy1wb3J0LTMxOTk5LW5vLXNhdmUuY29uZg==
					FolderItem = Li4vLi4vQ29weSUyMEludG8lMjBQcm9qZWN0cy9SZWRpcyUyMFNlcnZlciUyME1hYy8=
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
			End
#tag EndBuildAutomation
