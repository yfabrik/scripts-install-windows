:: disable telemetry
sc config DiagTrack start= disabled
sc config dmwappushservice start= disabled

sc stop DiagTrack
sc stop dmwappushservice 

schtasks /delete /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /f

:: password never expire
net accounts /MAXPWAGE:UNLIMITED
