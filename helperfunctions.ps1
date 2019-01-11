#4/27/2018

#This file contains small 'helper' functions that dont really belong elsewhere and aren't 
#complex enough to warrant their own file

function Remove-AllPSSession {
	Get-PSSession | Remove-PSSession
}