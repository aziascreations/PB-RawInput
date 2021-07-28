;{- Code Header
; ==- Basic Info -================================
;         Name: RawInput.pbi
;      Version: 1.0.0
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

; FIXME: Not tested on X86 !


;- Compiler Directives

;EnableExplicit
XIncludeFile "./WinTypes.pbi"

CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
	CompilerError("RawInput.pbi can only be compiled for Windows platforms !")
CompilerEndIf


;- Module Declaration

DeclareModule RawInput
	;-> Semver Data
	
	#Version_Major = 1
	#Version_Minor = 0
	#Version_Patch = 0
	#Version_Label$ = ""
	#Version$ = "1.0.0";+"-"+#Version_Label$
	
	
	;-> Library Path Declaration
	
	; Note: It could be possible to use the one from PureBasic itself too.
	#LibPath_User32_x86$ = "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86\User32.lib"
	#LibPath_User32_x64$ = "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64\User32.lib"
	
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		#LibPath_User32$ = #LibPath_User32_x86$
	CompilerElseIf #PB_Compiler_Processor = #PB_Processor_x64
		#LibPath_User32$ = #LibPath_User32_x64$
	CompilerElse
		CompilerError("Unable to compile for the current CPU architecture !")
	CompilerEndIf
	
	
	;-> Structures & Structure Macros
	; https://docs.microsoft.com/en-us/windows/win32/inputdev/raw-input#structures
	
	; https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rawmouse
	Structure tagRAWMOUSE_DUMMYSTRUCTNAME Align #PB_Structure_AlignC
		usButtonFlags.WinTypes::USHORT
		usButtonData.WinTypes::USHORT
	EndStructure
	
	Structure tagRAWMOUSE Align #PB_Structure_AlignC
		usFlags.WinTypes::USHORT
		StructureUnion
			ulButtons.WinTypes::ULONG
			DUMMYSTRUCTNAME.tagRAWMOUSE_DUMMYSTRUCTNAME
		EndStructureUnion
		ulRawButtons.WinTypes::ULONG
		lLastX.WinTypes::LONG
		lLastY.WinTypes::LONG
		ulExtraInformation.WinTypes::ULONG
	EndStructure
	
	Macro RAWMOUSE : RawInput::tagRAWMOUSE : EndMacro
	Macro PRAWMOUSE : i : EndMacro
	Macro LPRAWMOUSE : i : EndMacro
	
	; https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rawkeyboard
	Structure tagRAWKEYBOARD Align #PB_Structure_AlignC
		MakeCode.WinTypes::USHORT
		Flags.WinTypes::USHORT
		Reserved.WinTypes::USHORT
		VKey.WinTypes::USHORT
		Message.WinTypes::UINT
		ExtraInformation.WinTypes::ULONG
	EndStructure
	
	Macro RAWKEYBOARD : RawInput::tagRAWKEYBOARD : EndMacro
	Macro PRAWKEYBOARD : i : EndMacro
	Macro LPRAWKEYBOARD : i : EndMacro
	
	; https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rawhid
	; Each WM_INPUT can indicate several inputs, but all of the inputs come from the same HID.
	; The size of the bRawData array is dwSizeHid * dwCount.
	Structure tagRAWHID Align #PB_Structure_AlignC
		dwSizeHid.WinTypes::DWORD
		dwCount.WinTypes::DWORD
		bRawData.WinTypes::BYTE[1]
	EndStructure
	
	Macro RAWHID : RawInput::tagRAWHID : EndMacro
	Macro PRAWHID : i : EndMacro
	Macro LPRAWHID : i : EndMacro
	
	; https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rawinputheader
	; Size may vary due to use of .i types (x86 not verified fully !)
	Structure tagRAWINPUTHEADER Align #PB_Structure_AlignC
		dwType.WinTypes::DWORD
		dwSize.WinTypes::DWORD
		hDevice.WinTypes::HANDLE
		wParam.WinTypes::WPARAM
	EndStructure
	
	Macro RAWINPUTHEADER : RawInput::tagRAWINPUTHEADER : EndMacro
	Macro PRAWINPUTHEADER : i : EndMacro
	Macro LPRAWINPUTHEADER : i : EndMacro
	
	; https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rawinput
	Structure tagRAWINPUT Align #PB_Structure_AlignC
		header.RAWINPUTHEADER
		StructureUnion
			mouse.RAWMOUSE
			keyboard.RAWKEYBOARD
			hid.RAWHID
		EndStructureUnion
	EndStructure
	
	Macro RAWINPUT : RawInput::tagRAWINPUT : EndMacro
	Macro PRAWINPUT : i : EndMacro
	Macro LPRAWINPUT : i : EndMacro
	
	; https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rawinputdevice
	; Size may vary due to use of .i types (x86 not verified fully !)
	Structure tagRAWINPUTDEVICE Align #PB_Structure_AlignC
		usUsagePage.WinTypes::USHORT
		usUsage.WinTypes::USHORT
		dwFlags.WinTypes::DWORD
		hwndTarget.WinTypes::HWND
	EndStructure
	
	Macro RAWINPUTDEVICE : RawInput::tagRAWINPUTDEVICE : EndMacro
	Macro PRAWINPUTDEVICE : i : EndMacro
	Macro LPRAWINPUTDEVICE : i : EndMacro
	
	; https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rawinputdevicelist
	; Size may vary due to use of .i types (x86 not verified fully !)
	Structure tagRAWINPUTDEVICELIST Align #PB_Structure_AlignC
		hDevice.WinTypes::HANDLE
		dwType.WinTypes::DWORD
	EndStructure
	
	Macro RAWINPUTDEVICELIST : RawInput::tagRAWINPUTDEVICELIST : EndMacro
	Macro PRAWINPUTDEVICELIST : i : EndMacro
	
	; https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rid_device_info_hid
	Structure tagRID_DEVICE_INFO_HID Align #PB_Structure_AlignC
		dwVendorId.WinTypes::DWORD
		dwProductId.WinTypes::DWORD
		dwVersionNumber.WinTypes::DWORD
		usUsagePage.WinTypes::USHORT
		usUsage.WinTypes::USHORT
	EndStructure
	
	Macro RID_DEVICE_INFO_HID : RawInput::tagRID_DEVICE_INFO_HID : EndMacro
	Macro PRID_DEVICE_INFO_HID : i : EndMacro
	
	; https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rid_device_info_keyboard
	Structure tagRID_DEVICE_INFO_KEYBOARD Align #PB_Structure_AlignC
		dwTyp.WinTypes::DWORD
		dwSubType.WinTypes::DWORD
		dwKeyboardMode.WinTypes::DWORD
		dwNumberOfFunctionKeys.WinTypes::DWORD
		dwNumberOfIndicators.WinTypes::DWORD
		dwNumberOfKeysTotal.WinTypes::DWORD
	EndStructure
	
	Macro RID_DEVICE_INFO_KEYBOARD : RawInput::tagRID_DEVICE_INFO_KEYBOARD : EndMacro
	Macro PRID_DEVICE_INFO_KEYBOARD : i : EndMacro
	
	; https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rid_device_info_mouse
	Structure tagRID_DEVICE_INFO_MOUSE Align #PB_Structure_AlignC
		dwId.WinTypes::DWORD
		dwNumberOfButtons.WinTypes::DWORD
		dwSampleRate.WinTypes::DWORD
		fHasHorizontalWheel.WinTypes::BOOL
	EndStructure
	
	Macro RID_DEVICE_INFO_MOUSE : RawInput::tagRID_DEVICE_INFO_MOUSE : EndMacro
	Macro PRID_DEVICE_INFO_MOUSE : i : EndMacro
	
	; https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rid_device_info
	Structure tagRID_DEVICE_INFO Align #PB_Structure_AlignC
		cbSize.WinTypes::DWORD
		dwType.WinTypes::DWORD
		StructureUnion
			mouse.RID_DEVICE_INFO_MOUSE
			keyboard.RID_DEVICE_INFO_KEYBOARD
			hid.RID_DEVICE_INFO_HID
		EndStructureUnion
	EndStructure
	
	Macro RID_DEVICE_INFO : RawInput::tagRID_DEVICE_INFO : EndMacro
	Macro PRID_DEVICE_INFO : i : EndMacro
	Macro LPRID_DEVICE_INFO : i : EndMacro	
	
	
	;-> Structure Constants
	
	; Type of raw input (tagRAWINPUTHEADER\dwType & tagRID_DEVICE_INFO\dwType)
	#RIM_TYPEMOUSE = 0	  ; Raw input comes from the mouse.
	#RIM_TYPEKEYBOARD = 1 ; Raw input comes from the keyboard.
	#RIM_TYPEHID = 2	  ; Raw input comes from some device that is not a keyboard or a mouse.
	
	; The mouse state (tagRAWMOUSE\usFlags)
	#MOUSE_MOVE_RELATIVE = $00      ; Mouse movement data is relative to the last mouse position.
	#MOUSE_MOVE_ABSOLUTE = $01		; Mouse movement data is based on absolute position.
	#MOUSE_VIRTUAL_DESKTOP = $02	; Mouse coordinates are mapped to the virtual desktop (for a multiple monitor system).
	#MOUSE_ATTRIBUTES_CHANGED = $04	; Mouse attributes changed
									; Application needs to query the mouse attributes.
	#MOUSE_MOVE_NOCOALESCE = $08	; This mouse movement event was not coalesced. Mouse movement events can be coalescened by default.
									; Windows XP/2000: This value is not supported.
	
	; The mouse state (tagRAWMOUSE\DUMMYSTRUCTNAME\usButtonFlags)
	#RI_MOUSE_BUTTON_1_DOWN = $0001 ; Left button changed to down.
	#RI_MOUSE_BUTTON_1_UP = $0002	; Left button changed to up.
	#RI_MOUSE_BUTTON_2_DOWN = $0004	; Right button changed to down.
	#RI_MOUSE_BUTTON_2_UP = $0008	; Right button changed to up.
	#RI_MOUSE_BUTTON_3_DOWN = $0010	; Middle button changed to down.
	#RI_MOUSE_BUTTON_3_UP = $0020	; Middle button changed to up.
	#RI_MOUSE_BUTTON_4_DOWN = $0040	; XBUTTON1 changed to down.
	#RI_MOUSE_BUTTON_4_UP = $0080	; XBUTTON1 changed to up.
	#RI_MOUSE_BUTTON_5_DOWN = $0100	; XBUTTON2 changed to down.
	#RI_MOUSE_BUTTON_5_UP = $0200	; XBUTTON2 changed to up.
	#RI_MOUSE_WHEEL = $0400			; Raw input comes from a mouse wheel
	#RI_MOUSE_HWHEEL = $0800		; Raw input comes from a horizontal mouse wheel.
									; The wheel delta is stored in usButtonData.
									; A positive value indicates that the wheel was rotated to the right.
									; A negative value indicates that the wheel was rotated to the left.
									; Windows XP/2000: This value is not supported.
	
	#RI_MOUSE_LEFT_BUTTON_DOWN = #RI_MOUSE_BUTTON_1_DOWN
	#RI_MOUSE_LEFT_BUTTON_UP = #RI_MOUSE_BUTTON_1_UP
	#RI_MOUSE_RIGHT_BUTTON_DOWN = #RI_MOUSE_BUTTON_2_DOWN
	#RI_MOUSE_RIGHT_BUTTON_UP = #RI_MOUSE_BUTTON_2_UP
	#RI_MOUSE_MIDDLE_BUTTON_DOWN = #RI_MOUSE_BUTTON_3_DOWN
	#RI_MOUSE_MIDDLE_BUTTON_UP = #RI_MOUSE_BUTTON_3_UP
	
	; TODO: Keyboard Flags
	
	; Mode flag (tagRAWINPUTDEVICE\dwFlags)
	#RIDEV_REMOVE = $00000001    ; If set, this removes the top level collection from the inclusion list.
								 ; This tells the operating system to stop reading from a device which matches the top level collection.
	#RIDEV_EXCLUDE = $00000010	 ; If set, this specifies the top level collections to exclude when reading a complete usage page.
								 ; This flag only affects a TLC whose usage page is already specified with #RIDEV_PAGEONLY.
	#RIDEV_PAGEONLY = $00000020	 ; If set, this specifies all devices whose top level collection is from the specified usUsagePage.
								 ; Note that usUsage must be zero. To exclude a particular top level collection, use #RIDEV_EXCLUDE.
	#RIDEV_NOLEGACY = $00000030	 ; If set, this prevents any devices specified by usUsagePage or usUsage from generating legacy messages.
								 ; This is only for the mouse and keyboard.
	#RIDEV_INPUTSINK = $00000100 ; If set, this enables the caller to receive the input even when the caller is not in the foreground.
								 ; Note that hwndTarget must be specified.
	#RIDEV_CAPTUREMOUSE = $00000200 ; If set, the mouse button click does not activate the other window.
									; #RIDEV_CAPTUREMOUSE can be specified only if #RIDEV_NOLEGACY is specified for a mouse device.
	#RIDEV_NOHOTKEYS = $00000200	; If set, the application-defined keyboard device hotkeys are not handled.
									; However, the system hotkeys; for example, ALT+TAB and CTRL+ALT+DEL, are still handled.
									; By default, all keyboard hotkeys are handled.
									; #RIDEV_NOHOTKEYS can be specified even if #RIDEV_NOLEGACY is not specified and hwndTarget is NULL.
	#RIDEV_APPKEYS = $00000400		; If set, the application command keys are handled.
									; #RIDEV_APPKEYS can be specified only if #RIDEV_NOLEGACY is specified for a keyboard device.
	#RIDEV_EXINPUTSINK = $00001000	; If set, this enables the caller to receive input in the background only if the foreground application does not process it.
									; In other words, if the foreground application is not registered for raw input, then the background application that is registered will receive the input.
									; Windows XP: This flag is not supported until Windows Vista
	#RIDEV_DEVNOTIFY = $00002000	; If set, this enables the caller to receive WM_INPUT_DEVICE_CHANGE notifications for device arrival and device removal.
									; Windows XP: This flag is not supported until Windows Vista
	
	; The type of device (tagRAWINPUTDEVICELIST\dwType)
	#RIM_TYPEMOUSE = 0	  ; The device is a mouse.
	#RIM_TYPEKEYBOARD = 1 ; The device is a keyboard.
	#RIM_TYPEHID = 2	  ; The device is an HID that is not a keyboard and not a mouse.
	
	; The type of keyboard (tagRID_DEVICE_INFO_KEYBOARD\dwType)
	#RI_KEYBOARDTYPE_101 = $4 ; Enhanced 101- or 102-key keyboards (and compatibles)
	#RI_KEYBOARDTYPE_JAPANESE = $7 ; Japanese Keyboard
	#RI_KEYBOARDTYPE_KOREAN = $8   ; Korean Keyboard
	#RI_KEYBOARDTYPE_UNKNOWN = $51 ; Unknown type or HID keyboard
	#RI_KEYBOARDTYPE_102 = #RI_KEYBOARDTYPE_101
	; For information about keyboard types, subtypes, scan code modes, and related keyboard layouts,
	; see the documentation in kbd.h, ntdd8042.h and ntddkbd.h headers in Windows SDK, and the Keyboard Layout Samples.
	
	; The bitfield of the mouse device identification properties (tagRID_DEVICE_INFO_MOUSE\dwId)
	#MOUSE_HID_HARDWARE = $0080 ; HID mouse
	#WHEELMOUSE_HID_HARDWARE = $0100 ; HID wheel mouse
	#HORIZONTAL_WHEEL_PRESENT = $8000; Mouse with horizontal wheel
	
	
	;-> Remaining Type Macros
	
	Macro HRAWINPUT : WinTypes::HANDLE : EndMacro
	Macro PCRAWINPUTDEVICE : i : EndMacro ; TMP
	
	
	;-> Library Importation
	
	Import #LibPath_User32$
		; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-defrawinputproc
		;DefRawInputProc.WinTypes::LRESULT(*paRawInput.PRAWINPUT, nInput.WinTypes::INT, cbSizeHeader.WinTypes::UINT)
		DefRawInputProc.WinTypes::LRESULT(*paRawInput, nInput.WinTypes::INT, cbSizeHeader.WinTypes::UINT)
		
		; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getrawinputbuffer
		GetRawInputBuffer.WinTypes::UINT(pData.PRAWINPUT, pcbSize.WinTypes::PUINT, cbSizeHeader.WinTypes::UINT)
		
		; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getrawinputdata
		GetRawInputData.WinTypes::UINT(hRawInput.HRAWINPUT, uiCommand.WinTypes::UINT, pData.WinTypes::LPVOID,
		                               pcbSize.WinTypes::PUINT, cbSizeHeader.WinTypes::UINT)
		
		CompilerIf #PB_Compiler_Unicode
			; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getrawinputdeviceinfow
			GetRawInputDeviceInfo.WinTypes::UINT(hDevice.WinTypes::HANDLE, uiCommand.WinTypes::UINT,
			                                     pData.WinTypes::LPVOID, pcbSize.WinTypes::PUINT ) As "GetRawInputDeviceInfoW"
		CompilerElse
			; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getrawinputdeviceinfoa
			GetRawInputDeviceInfo.WinTypes::UINT(hDevice.WinTypes::HANDLE, uiCommand.WinTypes::UINT,
			                                     pData.WinTypes::LPVOID, pcbSize.WinTypes::PUINT ) As "GetRawInputDeviceInfoA"
		CompilerEndIf
		
		; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getrawinputdevicelist
		GetRawInputDeviceList.WinTypes::UINT(pRawInputDeviceList.PRAWINPUTDEVICELIST, puiNumDevices.WinTypes::PUINT,
		                                     cbSize.WinTypes::UINT)
		
		; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getregisteredrawinputdevices
		GetRegisteredRawInputDevices.WinTypes::UINT(pRawInputDevices.PRAWINPUTDEVICE, puiNumDevices.WinTypes::PUINT,
		                                            cbSize.WinTypes::UINT)
		
		; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-registerrawinputdevices
		RegisterRawInputDevices.WinTypes::Bool(pRawInputDevices.PCRAWINPUTDEVICE, uiNumDevices.WinTypes::UINT,
		                                       cbSize.WinTypes::UINT)
	EndImport
	
	
	;-> Function Constants
	
	; GetRawInputData - uiCommand
	#RID_HEADER = $10000005 ; Get the header information from the RAWINPUT structure.
	#RID_INPUT = $10000003	; Get the raw data from the RAWINPUT structure.
	
	; GetRawInputDeviceInfo - uiCommand
	#RIDI_PREPARSEDDATA = $20000005 ; pData is a PHIDP_PREPARSED_DATA pointer to a buffer for a top-level collection's preparsed data.
	
	#RIDI_DEVICENAME = $20000007 ; pData points to a string that contains the device interface name.
								 ; If this device is opened with Shared Access Mode then you can call CreateFile with this name to open a HID collection and use returned handle for calling ReadFile to read input reports and WriteFile to send output reports.
								 ; For this uiCommand only, the value in pcbSize is the character count (not the byte count).
	
	#RIDI_DEVICEINFO = $2000000b ; pData points to an RID_DEVICE_INFO structure.
	
	
EndDeclareModule


;- Module Definition

Module RawInput
	; Nothing...
EndModule


;- Tests

CompilerIf #PB_Compiler_IsMainFile
	Debug "SizeOf(tagRAWMOUSE) = "+Str(SizeOf(RawInput::tagRAWMOUSE))
	Debug "SizeOf(tagRAWKEYBOARD) = "+Str(SizeOf(RawInput::tagRAWKEYBOARD))
	Debug "SizeOf(tagRAWHID) = "+Str(SizeOf(RawInput::tagRAWHID))
	Debug "SizeOf(tagRAWINPUTHEADER) = "+Str(SizeOf(RawInput::tagRAWINPUTHEADER))
	Debug "SizeOf(tagRAWINPUT) = "+Str(SizeOf(RawInput::tagRAWINPUT))
	Debug "SizeOf(tagRAWINPUTDEVICE) = "+Str(SizeOf(RawInput::tagRAWINPUTDEVICE))
	Debug "SizeOf(tagRAWINPUTDEVICELIST) = "+Str(SizeOf(RawInput::tagRAWINPUTDEVICELIST))
	Debug "SizeOf(tagRID_DEVICE_INFO_HID) = "+Str(SizeOf(RawInput::tagRID_DEVICE_INFO_HID))
	Debug "SizeOf(tagRID_DEVICE_INFO_KEYBOARD) = "+Str(SizeOf(RawInput::tagRID_DEVICE_INFO_KEYBOARD))
	Debug "SizeOf(tagRID_DEVICE_INFO_MOUSE) = "+Str(SizeOf(RawInput::tagRID_DEVICE_INFO_MOUSE))
	Debug "SizeOf(tagRID_DEVICE_INFO) = "+Str(SizeOf(RawInput::tagRID_DEVICE_INFO))
CompilerEndIf
