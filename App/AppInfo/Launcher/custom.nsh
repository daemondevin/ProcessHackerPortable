
;= LAUNCHER
;= ################
; This PAF was compiled using a modified version of PAL:
; https://github.com/demondevin/portableapps.comlauncher

;= VARIABLES 
;= ################
 
;= DEFINES
;= ################
!define /redef APPDIR	`$EXEDIR\App\${APP}\x86`
!define /redef APPDIR64	`$EXEDIR\App\${APP}\x64`
!define 32				ProcessHacker\x86\ProcessHacker.exe
!define 64				ProcessHacker\x64\ProcessHacker.exe
!define EXE				`$EXEDIR\App\ProcessHacker\$1\ProcessHacker.exe`
!define EXE64			`$EXEDIR\App\${64}`
!define XML				`${SET}\ProcessHacker.exe.settings.xml`
!define DEFXML			`${DEFSET}\ProcessHacker.exe.settings.xml`
!define SVC				`KProcessHacker3`
!define KPH				`${APPDIR}\kprocesshacker.sys`
!define KPH64			`${APPDIR64}\kprocesshacker.sys`
!define SVCKEY			SYSTEM\CurrentControlSet\services\${SVC}
!define HKLM			HKLM\${SCKEY}
!define TASK			`SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe`
!define SET32			`Kernel32::SetEnvironmentVariable(t "PROHACK", t "x86")`
!define SET64			`Kernel32::SetEnvironmentVariable(t "PROHACK", t "x64")`

;= FUNCTIONS
;= ################

;= MACROS
;= ################
!define MsgBox "!insertmacro MsgBox"
!macro MsgBox
	StrCpy $0 `Windows XP +`
	MessageBox MB_ICONSTOP|MB_TOPMOST `$(MINREQ)`
	Call Unload
	Quit
!macroend

;= CUSTOM 
;= ################
${SegmentFile}
${Segment.OnInit}
	Push $0
	System::Call `${GETCURRPROC}`
	System::Call `${WOW}`
	StrCmp $0 0 ThirtyTwoBit
	IfFileExists `${EXE64}` 0 EightySixBit
	SetRegView 64
	System::Call `${SET64}`
	${WriteSettings} 64 Architecture
		Goto END
	EightySixBit:
	System::Call `${SET32}`
	${WriteSettings} 64 Architecture
		Goto END
	ThirtyTwoBit:
	System::Call `${SET32}`
	${WriteSettings} 32 Architecture
	END:
	Pop $0
!macroend
!macro ProExecInit
	Push $0
	ReadEnvStr $0 PROHACK
	StrCmp $0 x86 0 +3
	StrCpy $ProgramExecutable ${32}
	Goto +2
	StrCpy $ProgramExecutable ${64}
	Pop $0
!macroend
!macro RunAsAdmin
	Push $0
	${ConfigReads} `${CONFIG}` KProcessHacker= $0
	${If} $0 == true
		${If} ${RunningX64}
			ReadEnvStr $0 PROHACK
			${If} $0 == x86
				MessageBox MB_ICONINFORMATION|MB_TOPMOST `KProcessHacker is incompatible with x86`
				${ConfigWrites} `${CONFIG}` KProcessHacker= false $0
			${Else}
				StrCpy $RunAsAdmin force
			${EndIf}
		${Else}
			StrCpy $RunAsAdmin force
		${EndIf}
	${ElseIf} $0 == auto
		${If} ${RunningX64}
			ReadEnvStr $0 PROHACK
			${If} $0 == x64
				${If} ${IsAdmin}
					StrCpy $RunAsAdmin force
				${EndIf}
			${EndIf}
		${Else}
			${If} ${IsAdmin}
				StrCpy $RunAsAdmin force
			${EndIf}
		${EndIf}
	${EndIf}
	Pop $0
!macroend
!macro RunAsAdminOverride
	${If} $SecondaryLaunch != true
	${AndIf} ${ProcessExists} ProcessHacker.exe
		Quit
	${EndIf}
!macroend
!macro OS
	Push $0
	${If} ${IsNT}
		${If} ${IsWinXP}
			${IfNot} ${AtLeastServicePack} 2
				MessageBox MB_ICONSTOP|MB_TOPMOST `${PORTABLEAPPNAME} requires Service Pack 2 or newer`
				Call Unload
				Quit
			${EndIf}
		${ElseIfNot} ${AtLeastWinXP}
			${MsgBox}
		${EndIf}
	${Else}
		${MsgBox}
	${EndIf}
	Pop $0
!macroend
!macro PreServices
	${If} $RunAsAdmin == force
		${If} ${AtLeastWin7}
			ClearErrors
			EnumRegKey $0 HKLM `${SVCKEY}` 0
			IfErrors +4
			${WriteRuntimeData} ${PAL} ${SVC} 1
			${Registry::BackupKey} `${HKLM}` $0
		${EndIf}
	${EndIf}
!macroend
!macro PrePrimaryServices
	${If} $RunAsAdmin == force
		${If} ${AtLeastWin7}
			${If} $Bit == 64
				${SC::Create} ${SVC} `${KPH64}` kernel driver "" /DISABLEFSR $1 $2
				${SC::Start} ${SVC} /DISABLEFSR $1 $2
			${Else}
				${SC::Create} ${SVC} `${KPH}` kernel driver "" /DISABLEFSR $1 $2
				${SC::Start} ${SVC} /DISABLEFSR $1 $2
			${EndIf}
		${EndIf}
	${EndIf}
!macroend
!macro PostPrimaryServices
	${If} $RunAsAdmin == force
		${If} ${AtLeastWin7}
			${SC::Stop} ${SVC} /DISABLEFSR $1 $2
			ClearErrors
			${ReadRuntimeData} $0 ${PAL} ${SVC}
			${If} ${Errors}
				${SC::Delete} ${SVC} /DISABLEFSR $1 $2
			${EndIf}
			${Registry::RestoreBackupKey} `${HKLM}` $0
		${EndIf}
	${EndIf}
!macroend
!macro PreReg
	Push $0
	ClearErrors
	ReadRegStr $0 HKLM `${TASK}` Debugger
	IfErrors +3
	WriteINIStr "${RUNTIME}" ${PAL} Debugger "$0"
	WriteINIStr "${RUNTIME2}" ${PAL} Debugger "$0"
	Pop $0
!macroend
!macro PostReg
	Push $0
	Push $1
	ReadRegStr $0 HKLM `${TASK}` Debugger
	ReadEnvStr $1 PROHACK
	${If} $0 == `"${EXE}"`
		DeleteRegKey HKLM `${TASK}`
		ClearErrors
		${ReadRuntimeData} $0 ${PAL} Debugger
		IfErrors +2
		WriteRegStr HKLM `${TASK}` Debugger `$0`
	${EndIf}
	Pop $1
	Pop $0
!macroend