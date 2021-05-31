'
' 
' 
Global Integer NumGeomBoltFound, BoltCount, NumCorrBoltFound, NumBoltsOnSideFound
Global Boolean IsGeomBoltFound, IsCorrBoltFound
Global Integer OringCount, NumCorrOringFound
Global Boolean IsCorrOringFound

Global Real BPX, BPY, BPU
Global Real OPX, OPY, OPU
'
Global Preserve Long g_cyclecount
Integer cycles_completed

'Function main
'	Integer i 'Successful bolt drop
'	Integer OringFound '0 = not found, 1 = found
'	Integer BoltFound '1 = not found, 1 = found
'	Integer MaxBoltCycles, MaxOringCycles 'max attempts to shake,vibrate
'	Integer GetNextBoltResult
'	
'    i = 1
'    MaxBoltCycles = 10
'    MaxOringCycles = 10
'    cycles_completed = 0
    
'    'prompt user to reset global counter
'    g_cnt_rset = ResetGlobalCounter()
'	If g_cnt_rset = 1 Then
'		g_cyclecount = 0
'	EndIf
'    
'    Call InitRobot()
'    Jump AboveDropOff
'    On DropOff

'	Do
'		TmReset 0 'Reset Timer 0
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''' pick up oring '''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'		Print "pick oring"
'		Off Gripper
'		
'		OringFound = FindLrgOring()
'		
'		Integer cnt_o
'		cnt_o = 0
'		Do While OringFound = 0
'			' if loops Max times, then out of orings
'			If cnt_o > MaxBoltCycles Then
'				Exit Function
'			EndIf
'			
'			ShakeOring()
'			Wait 1.5
'			OringFound = FindLrgOring()
'		Loop
'		
'		Jump XY(OPX, OPY, -140, 0) /L ! D20; Off DropOff; D20; Off DropOffBad; !
'		OringFound = 0
'		On Gripper
'		On DropOff
'		On DropOffBad
		
''''''''''''''''''''''''''''''''''''''''''''''''''''''		
'''''''take picture of bolt. If not found call GetNextBolt '''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''		
'		BoltFound = FindBlackBolt()
'		If BoltFound = 0 Then
'			GetNextBolt()
'		
''''''''''''''''''''''''''''''''''''''''''''''''''''''		
'''''''''''''''' drop oring in nest ''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''
'		Print "Drop oring"
'		If BoltFound = 0 Then
'			Jump OringDrop C0 LimZ -75 ! D0; On BoltShaker; D10; Off BoltShaker !
'		Else
'			Jump OringDrop C0 LimZ -75
'		EndIf
'		
'		Off Gripper 'open gripper
'		
'		'''''''''''''''' tamp oring '''''''''''''''''''''''
'		Jump OringTamp C0 LimZ -90 CP
		
''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''' pickup bolt ''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'		Print "Find bolt"
'		If BoltFound = 0 Then
'			BoltFound = FindBlackBolt()
'		
'		Integer cnt_b
'		cnt_b = 0
'		Do While BoltFound = 0
'			' if loops Max times, then out of bolts
'			If cnt_b > MaxBoltCycles Then
'				Exit Function
'			EndIf
'			
'			GetNextBoltResult = GetNextBolt()
'			If GetNextBoltResult = 1 Then
'				Wait .5 'shake wait
'			Else
'				Wait 2 ' trough wait
'			EndIf
'				
'			BoltFound = FindBlackBolt()
'			Print BoltFound
'			cnt_b = cnt_b + 1
'		Loop
'	
'		Jump XY(BPX, BPY, -132, 0) /L C0
'		On Gripper
'		
'		BoltFound = 0 ' set for next iteration
		
''''''''''''''''''''''''''''''''''''''''''''''''''''''		
'''''''''''''''''''''''' safety pass thru '''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''		
'		Jump PassThru C3 LimZ -24 CP
		
''''''''''''''''''''''''''''''''''''''''''''''''''''''		
'''''''''''''''''''''''' marry bolt/oring '''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''
'		Print "Marry Bolt"
'		'Jump AboveNest C0 LimZ -24 CP
'		Go AboveNest 'CP
'		Go BottomNest
'		'Go AboveLrgNest4Bolt CP
''''''''''''''''''''''''''''''''''''''''''''''''''''''		
'''''''''''''''''''''''' Laser Verify and drop off ''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		
'		Go LaserCheck
'		Print "Laser Check"
'		Wait .5
'		If Sw(8) = 1 Then
'			Off DropOff
'			Jump DropOff C0 'CP
'			On DropOff
'			Go AboveDropOff CP
'			'Off DropOff
'			
'		Else
'			Off DropOffBad
'			Jump PassThru C0 LimZ -24 CP
'			Jump DropOffBad C0 LimZ -24
'			On DropOffBad
'			Go AboveDropOffBad
'			'Off DropOffBad
'		EndIf

''''''''''''''''''''''''''''''''''''''''''''''''''''''			
'''''''''''''''''''''''' reset counters for next cycle ''''	
''''''''''''''''''''''''''''''''''''''''''''''''''''''
'		If cycles_completed = 0 Then
'			Print "Bolt Count: ", g_cyclecount, Tmr(0)
'			Call FirstLoopOk()
'		EndIf
'		
'		g_cyclecount = g_cyclecount + 1
'		If i = 16 Then
'			Call BoxDone()
'			i = 1
'		Else
'			i = i + 1
'		EndIf
'		
'		Print g_cyclecount, Tmr(0)
'	Loop

'Fend
''''''''''''''''''''''''''''' Get Next bolt ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Function GetNextBolt As Integer
'	' if < 5 side bolts and no good bolts run trough
'	If NumBoltsOnSideFound < 5 And NumGeomBoltFound = 0 Then
'		BoltTroughCycle()
'		GetNextBolt = 2
'	Else
'		ShakeBolt()
'		GetNextBolt = 1
'Fend

''''''''''''''''''''''''''''' Initialize ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Function InitRobot
'	Integer g_cnt
'	
'	Reset			'Reset servos
'	If Motor = Off Then
'		Motor On
'	EndIf
'	Power Low		'Torque
'	Speed 40
'	Accel 50, 50  'Accel,Decel
'Fend



''''''''''''''''''''''''''''' First Loop Ok ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Function FirstLoopOk
'  String msg$, title$
'  Integer mFlags, answer
'  
'  'msg$ = Chr$(34) + "Operation complete" + Chr$(34) + CRLF
'  msg$ = "First Run Good?" + CRLF
'  msg$ = msg$ + "Ready to continue?"
'  title$ = "Sample Application"
'  mFlags = MB_YESNO + MB_ICONQUESTION
'  
'  MsgBox msg$, mFlags, title$, answer
'  If answer = IDNO Then
'    Quit All
'  EndIf
'  
'  Power High
'Fend

''''''''''''''''''''''''''''' First Loop ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Function FirstLoop
'	Power Low
'	Jump AboveDropOff C0
'Fend

''''''''''''''''''''''''''''' Box Done ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Function BoxDone
'	String msg$, title$
'  	Integer mFlags, answer
'  	
'  	'jump to home base
'  	Jump HomeBase
'  	
'  	' wait for ok to continue
'  	msg$ = "Box Finished"
'	title$ = "Replace Box"
'	mFlags = MB_OK + MB_ICONEXCLAMATION
'	MsgBox msg$, mFlags, title$, answer
'	If answer = IDOK Then
'		g_cyclecount = 0
'	EndIf
'	
'	
'Fend



''''''''''''''''''''''''''''' Find Black Bolt ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Function FindBlackBolt As Integer
'	
'	Integer COUNT
'	FindBlackBolt = 0
'
'	' Run sequence and get count of orings found
'	VRun Find_Black_Bolts
'	'VGet Find_Black_Bolts.Corr01.NumberFound, NumCorrBoltFound
'	VGet Find_Black_Bolts.Geom03.NumberFound, NumGeomBoltFound
'	VGet Find_Black_Bolts.Geom02.NumberFound, NumBoltsOnSideFound
'	
'	' if < 5 side bolts and no good bolts run trough
'	If NumBoltsOnSideFound < 5 And NumGeomBoltFound = 0 Then
'		BoltTroughCycle()
'	EndIf
'	
'	'If NumCorrBoltFound <> 0 Then
'	'	VGet Find_Black_Bolts.Corr01.RobotXYU(COUNT), IsCorrBoltFound, BPX, BPY, BPU
'	'	FindBlackBolt = 1
'	'	Exit Function
'	'EndIf
'	
'	If NumGeomBoltFound <> 0 Then
'		VGet Find_Black_Bolts.Geom03.RobotXYU(Count), IsGeomBoltFound, BPX, BPY, BPU
'		FindBlackBolt = 1
'	EndIf
'Fend
'
'''''''''''''''''''''''''''''' Find Oring ''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Function FindLrgOring As Integer
' 
'	Integer Count
'	FindLrgOring = 0
'	
'	' Run sequence and get count of orings found
'	VRun Find_Orings_Lrg
'	VGet Find_Orings_Lrg.Corr01.NumberFound, NumCorrOringFound
'	
'	If NumCorrOringFound <> 0 Then
'		VGet Find_Orings_Lrg.Corr01.RobotXYU(Count), IsCorrOringFound, OPX, OPY, OPU
'		FindLrgOring = 1
'		Exit Function
'	'Else
'	'	FindLrgOring = 0
'	EndIf
'Fend

''''''''''''''''''''''''''''' Shake Oring ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Function ShakeOring
'	Integer fnd
'	
'	On OringShaker
'	Wait .1
'	Off OringShaker
'	Wait 1
'	
'	' check if orings found now, if not must be low
'	fnd = FindLrgOring()
'	If fnd = 0 Then
'		OringTroughCycle()
'	EndIf
'Fend
'
'''''''''''''''''''''''''''''' Shake Bolt ''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Function ShakeBolt
'	On BoltShaker
'	Wait .1
'	Off BoltShaker
'Fend
'''''''''''''''''''''''''''''' Bolt Trough Cycle ''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Function BoltTroughCycle
'	On BoltTrough
'	Wait .1
'	Off BoltTrough
'Fend
'''''''''''''''''''''''''''''' Oring Trough Cycle ''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Function OringTroughCycle
'	On OringTrough
'	Wait .1
'	Off OringTrough
'Fend
''''''''''''''''''''''''''''' Reset Global Counter ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Function ResetGlobalCounter As Integer
'	String msg$, title$
'  	Integer mFlags, answer
'  	
'  	' wait for ok to continue
'  	msg$ = "Reset Bolt Counter?"
'	title$ = "Bolt Counter"
'	mFlags = MB_YESNO + MB_ICONQUESTION
'	MsgBox msg$, mFlags, title$, answer
'	If answer = IDYES Then
'		ResetGlobalCounter = 1
'	Else
'		ResetGlobalCounter = 0
'	EndIf
'Fend

