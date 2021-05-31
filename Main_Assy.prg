'
' 
' 
'''''''''''''''' image variables '''''''''''''''''''''''''''''''''''
Global Integer NumGeomBoltFound, BoltCount, NumCorrBoltFound, NumBoltsOnSideFound
Global Boolean IsGeomBoltFound, IsCorrBoltFound
Global Integer OringCount, NumCorrOringFound
Global Boolean IsCorrOringFound
Global Integer BoltFound '1 = not found, 1 = found
Global Integer OringFound '0 = not found, 1 = found
Global Real BPX, BPY, BPU
Global Real OPX, OPY, OPU

'''''''''''''''''' preserved counts '''''''''''''''''''''''''''''''''''''''''''
Global Preserve Long g_Good_Bolt_Cnt
Global Preserve Long g_Bad_Bolt_Cnt

''''''''''''''''''''''''' counts ''''''''''''''''''''''
Global Integer cycles_completed
Global Integer bad_cycles_completed
Global Integer GetNextBoltResult

'''''''''''''''''''' bolt constants ''''''''''''''''''''''''''''''
Global Integer MAX_BOLT_CYCLES, MAX_ORING_CYCLES 'max attempts to shake,vibrate
Global Integer BOLT_PICKUP_Z_HEIGHT, ORING_PICKUP_Z_HEIGHT
Global Real BOLT_TROUGH_CYCLE_TIME, ORING_TROUGH_CYCLE_TIME
Global Double BOLT_SHAKER_WAIT, ORING_SHAKER_WAIT
Global Double BOLT_TROUGH_WAIT, ORING_TROUGH_WAIT
Global Real BOLT_Z_LIM, ORING_Z_LIM
Global Real BOLT_VRUN_WAIT, ORING_VRUN_WAIT
Global Integer MIN_BOLTS_ON_SIDE
Global Double BOLT_EJECT_TIMER
Global Real BOLT_PICKUP_Z_LIMIT

''''''''''''''''''' other constants '''''''''''''''''''''''
Global Integer FULL_BOX_CNT
Global Integer MIN_BAD_CYCLES, MAX_BAD_CYCLES
Global Integer ROBOT_SPEED
Global Integer MOVE_SPEED


Function main
	'set bolt constants	
	MAX_BOLT_CYCLES = 10
	BOLT_PICKUP_Z_HEIGHT = -135
	BOLT_PICKUP_Z_LIMIT = -90
	BOLT_TROUGH_CYCLE_TIME = .25
	BOLT_SHAKER_WAIT = 1.5
	BOLT_TROUGH_WAIT = 2.0
	BOLT_VRUN_WAIT = .5
	MIN_BOLTS_ON_SIDE = 10
	BOLT_EJECT_TIMER = .019
	
	'set oring constants
	MAX_ORING_CYCLES = 5
	ORING_PICKUP_Z_HEIGHT = -140
	ORING_TROUGH_CYCLE_TIME = .25
	ORING_SHAKER_WAIT = 1.75
	ORING_TROUGH_WAIT = 2.5
	ORING_Z_LIM = -35
	ORING_VRUN_WAIT = .2
	
	'other constants
	FULL_BOX_CNT = 100
	MAX_BAD_CYCLES = 3
	MIN_BAD_CYCLES = 7
	ROBOT_SPEED = 30
	MOVE_SPEED = 800
	
	' set current run variables
	cycles_completed = 0
	bad_cycles_completed = 0
	
	' prompt user to reset global counter if needed
    ResetGlobalCounters()
    
    InitRobot()
    
	Do
		TmReset 0 'Reset Timer 0

		PickUpOring() 'and vrun find_black_bolts
		
		'FindBoltInOring()
		VGetBlackBolt()
		
		DropOring()
		
		''''''''only run vrun if last pass came up empty ''''''''''
		If (IsGeomBoltFound = False) And (IsCorrBoltFound = False) Then
			VRun Find_Black_Bolts
		EndIf
		
		Oring_Tamp()
		'On Gripper

		PickUpBolt()
	
		Bolt_Pass_Thru()

		MarryBolt()
		
		Laser_Check()
		
		ResetCounters()

	Loop

Fend

''''''''''''' test to print vision points ''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function PrintVisionPoints
	VRun Find_Black_Bolts
	Wait 1
	VGetBlackBolt()
	
	' when oring is found
	Print OPX, OPY, OPU
Fend

Function FindBoltInOring()
''''''''take picture of bolt. If not found call GetNextBolt '''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''		
		BoltFound = VGetBlackBolt()
		If BoltFound = 0 Then
			GetNextBolt()
		EndIf
Fend

''''''''''''''''''''''''' pick up oring '''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function PickUpOring()
	Integer i
	
	Print "pick oring"
	Off Gripper
	
	VRun Find_Orings_Lrg
	Wait ORING_VRUN_WAIT
	OringFound = VGetLrgOring()
	
	i = 0
	Do While OringFound = 0
		' if loops Max times, then out of orings
		If i > MAX_ORING_CYCLES Then
			'Error NoOringsFound
			GenericYesNoMessageBox("Add Orings", "Out of Orings")
			i = 0
		EndIf
		VRun Find_Orings_Lrg
		If i = 0 Then
			ShakeOring()
			Wait ORING_SHAKER_WAIT
		EndIf
		If i > 1 Then
			OringTroughCycle()
			Wait ORING_TROUGH_WAIT
		EndIf
		
		VRun Find_Orings_Lrg
		Wait ORING_VRUN_WAIT
		OringFound = VGetLrgOring()
		i = i + 1
	Loop
	
	''''''''''' calculate U position ''''''''''''''''''''''
	OPU = UCalcOring
	
	'take pic to start looking for bolts 
	VRun Find_Black_Bolts
	
	' when oring is found
	Jump XY(OPX, OPY, ORING_PICKUP_Z_HEIGHT, OPU) /R LimZ ORING_Z_LIM ! D20; Off DropOff; D20; Off DropOffBad; !
	OringFound = 0
	On Gripper
	On DropOff
	On DropOffBad
Fend

''''''''''''''''' drop oring in nest ''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function DropOring()
	Print "Drop oring"
	If BoltFound = 0 Then
		Jump OringDrop C0 LimZ -75 '! D0; On BoltShaker; D10; Off BoltShaker !
	Else
		Jump OringDrop C0 LimZ -75
	EndIf
	
	Off Gripper 'open gripper	
Fend

'''''''''''''''' tamp oring '''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''
Function Oring_Tamp
	Jump OringTamp C0 LimZ -90 CP
Fend

''''''''''''''''''' pickup bolt ''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function PickUpBolt()
	Integer i

	BoltFound = VGetBlackBolt()
	
	i = 0
	Do While BoltFound = 0
		' if loops Max times, then out of bolts
		If i > MAX_BOLT_CYCLES Then
			Print "No bolts found"
			'Error OutOfBolts
			GenericYesNoMessageBox("Add Bolts", "Out of Bolts")
			i = 0
		EndIf
		
		' run trough or shaker and wait
		GetNextBoltResult = GetNextBolt()
		If GetNextBoltResult = 1 Then
			Wait BOLT_SHAKER_WAIT
		Else
			Wait BOLT_TROUGH_WAIT
		EndIf
		
		' get next pic and wait to process
		VRun Find_Black_Bolts
		Wait BOLT_VRUN_WAIT
			
		' vget data
		BoltFound = VGetBlackBolt()
		Print "Bolt Found: ", BoltFound
		i = i + 1
	Loop
	
	''''''''''' calculate U position ''''''''''''''''''''''
	BPU = UCalcBolt
	
	'Print "BP_: ", BPX, BPY, BPU
	'SpeedS = 400
	Jump PassThruLow :U(BPU) LimZ -90 CP ! D50; On Gripper; !

	Jump XY(BPX, BPY, BOLT_PICKUP_Z_HEIGHT, BPU) /L C0 LimZ BOLT_PICKUP_Z_LIMIT ! D99; Off Gripper; !
	On Gripper
	
	BoltFound = 0 ' set for next iteration
		

Fend

'''''''''''''''''' turn U to avoid hitting shaker walls ''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function UCalcOring As Real
	If OPX < -275 Then
		UCalcOring = 180.0
	ElseIf OPY < 85 Then
		UCalcOring = -90.0
	ElseIf OPY > 310 Then
		UCalcOring = 90.0
	Else
		UCalcOring = 0
	EndIf
Fend

'''''''''''''''''' turn U to avoid hitting shaker walls ''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function UCalcBolt As Real
	If BPX < 90 Then
		UCalcBolt = 180.0
	ElseIf BPY < 85 Then
		UCalcBolt = -90.0
	ElseIf BPY > 310 Then
		UCalcBolt = 90.0
	Else
		UCalcBolt = 0
	EndIf
Fend

''''''''''''''''''''''' safety bolt pass thru '''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''	
Function Bolt_Pass_Thru()
	Jump PassThru C3 LimZ -24 CP
Fend

''''''''''''''''''''''' safety  oring pass thru '''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''	
Function Oring_Pass_Thru()
	Jump OringPassThru C3 LimZ -24 CP
Fend

''''''''''''''''''''''' marry bolt/oring '''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''
Function MarryBolt()
	Print "Marry Bolt"
	'Jump AboveNest C0 LimZ -24 CP
	Go AboveNest 'CP
	Go BottomNest
	'Go AboveLrgNest4Bolt CP
Fend
			
''''''''''''''''''''''' reset counters for next cycle ''''	
'''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ResetCounters()
	If cycles_completed = 0 Then
		'Print "Bolt Count: ", g_Good_Bolt_Cnt, Tmr(0)
		cycles_completed = 1
		Call FirstLoopOk()
	EndIf
	
	'check for complete box
	If g_Good_Bolt_Cnt = FULL_BOX_CNT Then
		Call BoxDone()
	EndIf
	
	Print "Bolt Count: ", g_Good_Bolt_Cnt, Tmr(0)
Fend
		
''''''''''''''''''''''' Laser Verify and drop off ''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function Laser_Check()
	Go LaserCheck
	Print "Laser Check"
	Wait .5
	If Sw(8) = 1 Then
		Off DropOff
		Jump DropOff C0 'CP
		On DropOff
		Go AboveDropOff CP
		g_Good_Bolt_Cnt = g_Good_Bolt_Cnt + 1
		bad_cycles_completed = 0
	Else
		Off DropOffBad
		Jump PassThru C0 LimZ -24 CP
		Jump DropOffBad C0 LimZ -24
		On DropOffBad
		Go AboveDropOffBad
		g_Bad_Bolt_Cnt = g_Bad_Bolt_Cnt + 1
		bad_cycles_completed = bad_cycles_completed + 1
		
		' shake bolts to clear possible issues
		ShakeBolt()
		
		' eject the oring and move home
		EjectOring()
		
		If bad_cycles_completed > MAX_BAD_CYCLES Then
			Error MaxBadCycReached
		EndIf
	EndIf

Fend

''''''''''''''''''''''''' Eject Oring '''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function EjectOring
	Jump Eject_Oring C5 LimZ -24
	On 4; Wait BOLT_EJECT_TIMER; Off 4
	Wait .3
	Go HomeBase CP
Fend

'''''''''''''''''''''''''''' Get Next bolt ''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function GetNextBolt As Integer
	' if < MIN_BAD_CYCLES side bolts and no good bolts run trough
	If NumBoltsOnSideFound < MIN_BOLTS_ON_SIDE And NumCorrBoltFound = 0 Then
		BoltTroughCycle()
		GetNextBolt = 2
	Else
		ShakeBolt()
		GetNextBolt = 1
	EndIf
Fend

'''''''''''''''''''''''''''' Initialize ''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function InitRobot
	Reset			'Reset servos
	If Motor = Off Then
		Motor On
	EndIf
	Power High		'Torque
	Speed ROBOT_SPEED
	'SpeedS 600
	Accel 40, 40  'Accel,Decel
	
	 ' jump to start area and open gripper to drop anything
    Jump HomeBase
    EjectOring()
    Off Gripper
    Wait .5
    On Gripper
    Wait .5
    Off Gripper
    
    On DropOff
Fend

''''''''''''''' generic message box '''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function GenericYesNoMessageBox(msg$ As String, title$ As String)
  	Integer answer, mFlags
  	mFlags = MB_YESNO + MB_ICONQUESTION
  
	MsgBox msg$, mFlags, title$, answer
	If answer = IDNO Then
	  Quit All
	EndIf

Fend

''''''''''''''''''''''''''''' First Loop Ok ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function FirstLoopOk
  String msg$, title$
  Integer mFlags, answer
  
  'msg$ = Chr$(34) + "Operation complete" + Chr$(34) + CRLF
  msg$ = "First Run Good?" + CRLF
  msg$ = msg$ + "Ready to continue?"
  title$ = "Sample Application"
  mFlags = MB_YESNO + MB_ICONQUESTION
  
  MsgBox msg$, mFlags, title$, answer
  If answer = IDNO Then
    Quit All
  EndIf
  
  Power High
Fend

''''''''''''''''''''''''''''' Box Done ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function BoxDone
	String msg$, title$
  	Integer mFlags, answer
  	
  	'jump to home base
  	Jump HomeBase
  	
  	' wait for ok to continue
  	msg$ = "Box Finished"
	title$ = "Replace Box"
	mFlags = MB_OK + MB_ICONEXCLAMATION
	MsgBox msg$, mFlags, title$, answer
	If answer = IDOK Then
		g_Good_Bolt_Cnt = 0
	EndIf
	
	
Fend

''''''''''''''''''''''''''''' Find Black Bolt ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function VGetBlackBolt As Integer
	VGetBlackBolt = 0
	
	' get number of bolts on side
	VGet Find_Black_Bolts.Geom02.NumberFound, NumBoltsOnSideFound
	Print NumBoltsOnSideFound
	
	VGet Find_Black_Bolts.Geom03.NumberFound, NumCorrBoltFound
	If NumCorrBoltFound <> 0 Then
		VGet Find_Black_Bolts.Geom03.RobotXYU(1), IsCorrBoltFound, BPX, BPY, BPU
		VGetBlackBolt = 1
		Exit Function
	EndIf
Fend

''''''''''''''''''''''''''''' Vget Large Oring ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function VGetLrgOring As Integer
	VGetLrgOring = 0
	
	' Run sequence and get count of orings found
	'VRun Find_Orings_Lrg
	VGet Find_Orings_Lrg.Corr01.NumberFound, NumCorrOringFound
	
	If NumCorrOringFound <> 0 Then
		VGet Find_Orings_Lrg.Corr01.RobotXYU(1), IsCorrOringFound, OPX, OPY, OPU
		VGetLrgOring = 1
	EndIf
Fend

''''''''''''''''''''''''''''' Shake Oring ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ShakeOring
	Integer fnd
	
	On OringShaker
	Wait .1
	Off OringShaker
Fend

''''''''''''''''''''''''''''' Shake Bolt ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ShakeBolt
	On BoltShaker
	Wait .1
	Off BoltShaker
Fend

''''''''''''''''''''''''''''' Bolt Trough Cycle ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function BoltTroughCycle
	On BoltTrough
	Wait BOLT_TROUGH_CYCLE_TIME
	Off BoltTrough
Fend

''''''''''''''''''''''''''''' Oring Trough Cycle ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function OringTroughCycle
	On OringTrough
	Wait ORING_TROUGH_CYCLE_TIME
	Off OringTrough
Fend

''''''''''''''''''''''''''''' Reset Global Counter ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ResetGlobalCounters As Integer
	String msg$, title$
  	Integer mFlags, answer
  	
  	' wait for ok to continue
  	msg$ = "Reset Bolt Counter?"
	title$ = "Bolt Counter"
	mFlags = MB_YESNO + MB_ICONQUESTION
	MsgBox msg$, mFlags, title$, answer
	If answer = IDYES Then
		g_Good_Bolt_Cnt = 0
		g_Bad_Bolt_Cnt = 0
	EndIf
Fend

