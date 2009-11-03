;

Name "ASE ISQL"

OutFile "AseIsqlSetup.exe"

SetCompressor lzma
Icon "install.ico"

; The default installation directory
InstallDir $PROGRAMFILES\AseIsql

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "SOFTWARE\FM2i\AseIsql" ""

; Pages

Page components

Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles



Section "ASE ISQL"
	SectionIn RO
	SetShellVarContext all
	SetOutPath $INSTDIR
	
	SetOverwrite on
	File "..\..\exe\*.dll"
	File "..\..\exe\*.exe"
	File "..\..\exe\*.hlp"
	File "..\..\exe\*.pbd"
	File "..\..\exe\keywords"
	File "..\..\exe\stubs.sql"
	SetOverwrite off
	File "..\..\exe\ustubs.sql"
	SetOverwrite on
	
	CreateShortCut "$SMPROGRAMS\Sybase\ASE ISQL.lnk" "$INSTDIR\aseisql.exe"
	
	
	WriteRegStr HKCR ".sql" "" "SQL_auto_file"
	WriteRegStr HKCR ".pro" "" "PRO_auto_file"
	WriteRegStr HKCR "SQL_auto_file\shell\open\command" "" '"$INSTDIR\aseisql.exe" "%1"'
	WriteRegStr HKCR "PRO_auto_file\shell\open\command" "" '"$INSTDIR\aseisql.exe" "%1"'
	
	WriteRegStr HKCR ".sws" "" "SWS_auto_file"
	WriteRegStr HKCR ".sws" "InfoTip" "ASE Isql workspace"
	WriteRegStr HKCR "SWS_auto_file\shell\open\command" "" '"$PROGRAMFILES\aseisql\aseisql.exe" "%1"'

	WriteRegStr HKCU "Software\Classes\Applications\aseisql.exe\shell\open\command" "" '"$INSTDIR\aseisql.exe" "%1"'

	; Write the installation path into the registry
	WriteRegStr HKLM "Software\FM2i\AseIsql" "" "$INSTDIR"

	;Create uninstaller
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ASE ISQL" "DisplayName" "ASE ISQL"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ASE ISQL" "UninstallString" '"$INSTDIR\Uninstall.exe"'
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ASE ISQL" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ASE ISQL" "NoRepair" 1
	WriteUninstaller "$INSTDIR\Uninstall.exe"
		
SectionEnd ; end the section

Section "Desktop shortcut"
	SetShellVarContext all
	CreateShortCut "$DESKTOP\ASE ISQL.lnk" "$INSTDIR\aseisql.exe"
SectionEnd

Section "Quick Launch shortcut"
	SetShellVarContext all
	CreateShortCut "$QUICKLAUNCH\ASE ISQL.lnk" "$INSTDIR\aseisql.exe"
SectionEnd

Section "Overwrite ustubs.sql" CopyUstubs
	SetShellVarContext all
	CopyFiles /FILESONLY "$EXEDIR\ustubs.sql" "$INSTDIR\ustubs.sql"
SectionEnd


Function .onInit
	IfFileExists $EXEDIR\ustubs.sql +2 0
	SectionSetFlags ${CopyUstubs} 16
	
	Push "mode"         ; push the search string onto the stack
	Push "normal"       ; push a default value onto the stack
	Call GetParameterValue
	Pop $R0
	
	StrCmp $R0 "silent" 0 +2 ; check if mode is silent
	SetSilent silent

FunctionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
	SetShellVarContext all
	; Remove registry keys
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ASE ISQL"

	DeleteRegKey HKLM "SOFTWARE\FM2i\aseisql"
	DeleteRegKey HKCU "SOFTWARE\FM2i\aseisql"
	DeleteRegKey HKCU "Software\Classes\Applications\aseisql.exe\shell\open\command"
	WriteRegStr HKCR "SQL_auto_file\shell\open\command" "" '"notepad.exe" "%1"'
	WriteRegStr HKCR "PRO_auto_file\shell\open\command" "" '"notepad.exe" "%1"'
	
	; Remove files and uninstaller
	RMDir /r $INSTDIR
	Delete "$DESKTOP\ASE ISQL.lnk"
	Delete "$QUICKLAUNCH\ASE ISQL.lnk"
	Delete "$SMPROGRAMS\Sybase\ASE ISQL.lnk"

SectionEnd



;----------------------FUNCTIONS-----------------------------
Function StrStr
	Exch $R1 ; st=haystack,old$R1, $R1=needle
	Exch    ; st=old$R1,haystack
	Exch $R2 ; st=old$R1,old$R2, $R2=haystack
	Push $R3
	Push $R4
	Push $R5
	StrLen $R3 $R1
	StrCpy $R4 0
	; $R1=needle
	; $R2=haystack
	; $R3=len(needle)
	; $R4=cnt
	; $R5=tmp
	loop:
	 StrCpy $R5 $R2 $R3 $R4
	 StrCmp $R5 $R1 done
	 StrCmp $R5 "" done
	 IntOp $R4 $R4 + 1
	 Goto loop
	done:
	StrCpy $R1 $R2 "" $R4
	Pop $R5
	Pop $R4
	Pop $R3
	Pop $R2
	Exch $R1
FunctionEnd


Function GetParameters
	Push $R0
	Push $R1
	Push $R2
	Push $R3

	StrCpy $R2 1
	StrLen $R3 $CMDLINE

	;Check for quote or space
	StrCpy $R0 $CMDLINE $R2
	StrCmp $R0 '"' 0 +3
		StrCpy $R1 '"'
		Goto loop
	StrCpy $R1 " "

	loop:
		IntOp $R2 $R2 + 1
		StrCpy $R0 $CMDLINE 1 $R2
		StrCmp $R0 $R1 get
		StrCmp $R2 $R3 get
		Goto loop

	get:
		IntOp $R2 $R2 + 1
		StrCpy $R0 $CMDLINE 1 $R2
		StrCmp $R0 " " get
		StrCpy $R0 $CMDLINE "" $R2

	Pop $R3
	Pop $R2
	Pop $R1
	Exch $R0
FunctionEnd


; GetParameterValue
; Chris Morgan<cmorgan@alum.wpi.edu> 5/10/2004
; -Updated 4/7/2005 to add support for retrieving a command line switch
;  and additional documentation
;
; Searches the command line input, retrieved using GetParameters, for the
; value of an option given the option name.  If no option is found the
; default value is placed on the top of the stack upon function return.
;
; This function can also be used to detect the existence of just a
; command line switch like /OUTPUT  Pass the default and "OUTPUT"
; on the stack like normal.  An empty return string "" will indicate
; that the switch was found, the default value indicates that
; neither a parameter or switch was found.
;
; Inputs - Top of stack is default if parameter isn't found,
;  second in stack is parameter to search for, ex. "OUTPUT"
; Outputs - Top of the stack contains the value of this parameter
;  So if the command line contained /OUTPUT=somedirectory, "somedirectory"
;  will be on the top of the stack when this function returns
;
; Register usage
;$R0 - default return value if the parameter isn't found
;$R1 - input parameter, for example OUTPUT from the above example
;$R2 - the length of the search, this is the search parameter+2
;      as we have '/OUTPUT='
;$R3 - the command line string
;$R4 - result from StrStr calls
;$R5 - search for ' ' or '"'
 
Function GetParameterValue
  Exch $R0  ; get the top of the stack(default parameter) into R0
  Exch      ; exchange the top of the stack(default) with
            ; the second in the stack(parameter to search for)
  Exch $R1  ; get the top of the stack(search parameter) into $R1
 
  ;Preserve on the stack the registers used in this function
  Push $R2
  Push $R3
  Push $R4
  Push $R5
 
  Strlen $R2 $R1+2    ; store the length of the search string into R2
 
  Call GetParameters  ; get the command line parameters
  Pop $R3             ; store the command line string in R3
 
  # search for quoted search string
  StrCpy $R5 '"'      ; later on we want to search for a open quote
  Push $R3            ; push the 'search in' string onto the stack
  Push '"/$R1='       ; push the 'search for'
  Call StrStr         ; search for the quoted parameter value
  Pop $R4
  StrCpy $R4 $R4 "" 1   ; skip over open quote character, "" means no maxlen
  StrCmp $R4 "" "" next ; if we didn't find an empty string go to next
 
  # search for non-quoted search string
  StrCpy $R5 ' '      ; later on we want to search for a space since we
                      ; didn't start with an open quote '"' we shouldn't
                      ; look for a close quote '"'
  Push $R3            ; push the command line back on the stack for searching
  Push '/$R1='        ; search for the non-quoted search string
  Call StrStr
  Pop $R4
 
  ; $R4 now contains the parameter string starting at the search string,
  ; if it was found
next:
  StrCmp $R4 "" check_for_switch ; if we didn't find anything then look for
                                 ; usage as a command line switch
  # copy the value after /$R1= by using StrCpy with an offset of $R2,
  # the length of '/OUTPUT='
  StrCpy $R0 $R4 "" $R2  ; copy commandline text beyond parameter into $R0
  # search for the next parameter so we can trim this extra text off
  Push $R0
  Push $R5            ; search for either the first space ' ', or the first
                      ; quote '"'
                      ; if we found '"/output' then we want to find the
                      ; ending ", as in '"/output=somevalue"'
                      ; if we found '/output' then we want to find the first
                      ; space after '/output=somevalue'
  Call StrStr         ; search for the next parameter
  Pop $R4
  StrCmp $R4 "" done  ; if 'somevalue' is missing, we are done
  StrLen $R4 $R4      ; get the length of 'somevalue' so we can copy this
                      ; text into our output buffer
  StrCpy $R0 $R0 -$R4 ; using the length of the string beyond the value,
                      ; copy only the value into $R0
  goto done           ; if we are in the parameter retrieval path skip over
                      ; the check for a command line switch
 
; See if the parameter was specified as a command line switch, like '/output'
check_for_switch:
  Push $R3            ; push the command line back on the stack for searching
  Push '/$R1'         ; search for the non-quoted search string
  Call StrStr
  Pop $R4
  StrCmp $R4 "" done  ; if we didn't find anything then use the default
  StrCpy $R0 ""       ; otherwise copy in an empty string since we found the
                      ; parameter, just didn't find a value
 
done:
  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Pop $R1
  Exch $R0 ; put the value in $R0 at the top of the stack
FunctionEnd
