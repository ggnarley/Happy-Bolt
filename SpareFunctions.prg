''''''''''''''''''''''''''''' Sample text input ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function GetPartName$ As String
  String prompt$, title$, answer$
  prompt$ = "Enter " + Chr$(34) + "part name" + Chr$(34) + ":"
  title$ = "Sample Application"
  InputBox prompt$, title$, "", answer$
  If answer$ <> "@" Then
  	GetPartName$ = answer$
  EndIf
Fend
''''''''''''''''''''''''''''' Sample Numbers input ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function InputNumbers
  Real A, B, C

  Print "Please enter 1 number"
  Input A
  Print "Please enter 2 numbers separated by a comma"
  Input B, C
  Print "A = ", A
  Print "B = ", B, " C = ", C
Fend

'''''''''''''''''''''Calibrate Oring Plate Z ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function CalOringPlateMain

	Integer answer
	answer = 1
	
	Jump PickOring
	Do While answer = 1
		answer = CalOringPlate()
		Print answer
	Loop
Fend
Function CalOringPlate As Integer
  String msg$, title$
  Integer mFlags, answer
  
  msg$ = "Lower .5 mm?" + CRLF
  'msg$ = msg$ + "Ready to continue?"
  title$ = "Oring Plate Calibration"
  mFlags = MB_YESNO + MB_ICONQUESTION
  
  'Jump PickOring
  
  MsgBox msg$, mFlags, title$, answer
  'If answer = IDNO Then
  ' 	Exit Function
  'EndIf
  CalOringPlate = 0
  
  If answer = IDYES Then
    Go Here +Z(10)
    Print "here"
    CalOringPlate = 1
  EndIf

	
	
Fend
''''''''''''''''''''''''''''' Read Input ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ReadInput
  Integer i, OringOk
  OringOk = Sw(8)
  'Check if feeder is ready
  If OringOk = On Then
  Print "Good Part" '  Call mkpart1
  Else
    Print "Bad Part"
    'Print "then restart program"
  EndIf
Fend
''''''''''''''''''''''''''''' Pause ''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function LoopPause
	String msg$, title$
  Integer mFlags, answer
  
  'msg$ = Chr$(34) + "Operation complete" + Chr$(34) + CRLF
  msg$ = "Paused" + CRLF
  msg$ = msg$ + "Ready to continue?"
  title$ = "Pause"
  mFlags = MB_YESNO + MB_ICONQUESTION
  
  MsgBox msg$, mFlags, title$, answer
  If answer = IDNO Then
    Quit All
  EndIf
Fend



