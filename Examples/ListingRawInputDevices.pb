;{- Code Header
; ==- Basic Info -================================
;         Name: ListingRawInputDevices.pb
;       Author: Herwin Bozet
;
; ==- Compatibility -=============================
;  Compiler version: PureBasic 5.70 (x64)
;  Operating system: Windows 10 21H1 (Previous versions untested)
; 
; ==- Sources -===================================
;  https://docs.microsoft.com/en-us/windows/win32/inputdev/raw-input
; 
; ==- Links & License -===========================
;  License: Unlicense
;  GitHub: https://github.com/aziascreations/PB-RawInput
;}

;- Notes

; Windows may combine some devices into so-called "virtual devices"
; https://stackoverflow.com/a/10331763/4135541

; For the errors, see: https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes


;- Compiler Directives

; EnableExplicit

CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
	CompilerError("ListingRawInputDevices.pb can only be compiled for Windows platforms !")
CompilerEndIf

XIncludeFile "../Includes/RawInput.pbi"


;- Code

; Counting RawInput devices...
Define RawInputDeviceCount.i = 0

If RawInput::GetRawInputDeviceList(#Null, @RawInputDeviceCount, SizeOf(RawInput::RAWINPUTDEVICELIST)) <> -1
	Debug "Found "+Str(RawInputDeviceCount)+" RawInput devices !"
Else
	Debug "Error while listing RawInput devices: "+Str(GetLastError_())+" !"
	End 1
EndIf


