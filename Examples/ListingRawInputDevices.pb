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

;-> Counting RawInput devices
Define RawInputDeviceCount.i = 0

If RawInput::GetRawInputDeviceList(#Null, @RawInputDeviceCount, SizeOf(RawInput::RAWINPUTDEVICELIST)) <> -1
	Debug "Found "+Str(RawInputDeviceCount)+" RawInput devices !"
Else
	Debug "Error while counting RawInput devices: "+Str(GetLastError_())+" !"
	End 1
EndIf


;-> Listing RawInput devices

; A memory buffer is used since we can't dynamically declare C-style arrays in PB.
Define *RawInputDeviceListBuffer = AllocateMemory(SizeOf(RawInput::RAWINPUTDEVICELIST) * RawInputDeviceCount)

If Not *RawInputDeviceListBuffer
	Debug "Failed to allocate memory for *RawInputDeviceListBuffer !"
	End 2
EndIf

Define ReturnedValue.WinTypes::UINT = RawInput::GetRawInputDeviceList(*RawInputDeviceListBuffer, @RawInputDeviceCount, SizeOf(RawInput::RAWINPUTDEVICELIST))
If ReturnedValue <> -1
	Debug "Successfully got the list of RawInput devices ! (Received "+Str(ReturnedValue)+" in the buffer)"
Else
	Debug "Error while listing RawInput devices: "+Str(GetLastError_())+" !"
	FreeMemory(*RawInputDeviceListBuffer)
	End 3
EndIf

Define i.i
For i=0 To RawInputDeviceCount - 1
	;-> > Getting an element from the buffer
	; From *RawInputDeviceListBuffer as a RAWINPUTDEVICELIST[] C-type array and type-casting it.
	; tagRAWINPUTDEVICELIST is used instead of RAWINPUTDEVICELIST for the auto-completion. (Same end result !)
	Define *RawInputDevice.RawInput::tagRAWINPUTDEVICELIST = *RawInputDeviceListBuffer + (SizeOf(RawInput::RAWINPUTDEVICELIST) * i)
	
	Debug #CRLF$+"Device #"+Str(i)
	
	; Printing the device's type
	Select *RawInputDevice\dwType
		Case RawInput::#RIM_TYPEHID
			Debug "> Device type: HID"
		Case RawInput::#RIM_TYPEKEYBOARD
			Debug "> Device type: Keyboard"
		Case RawInput::#RIM_TYPEMOUSE
			Debug "> Device type: Mouse"
		Default
			; Can happen due to off-by-one errors in loops !
			Debug "> Device type: Unknown (undocumented behaviour !)"
			Debug "  > "+Str(*RawInputDevice\dwType)
			Debug "  > 0x"+RSet(Hex(*RawInputDevice\dwType), 16, "0")
			Continue
	EndSelect
	
	;-> > Querying and printing the device's info
	; tagRID_DEVICE_INFO is used instead of RID_DEVICE_INFO for the auto-completion. (Same end result !)
	; GetRawInputDeviceInfoA or GetRawInputDeviceInfoW is automatically selected behing the scene.
	Debug "> Device info:"
	Define HasEncounteredAnError.b = #False
	
	; Getting the device's interface name (\\?\...)
	Define RawInputDeviceInterfaceName.s{#MAX_PATH}
	Define RawInputDeviceInterfaceNameSize = #MAX_PATH
	
	If RawInput::GetRawInputDeviceInfo(*RawInputDevice\hDevice, RawInput::#RIDI_DEVICENAME,
	                                   @RawInputDeviceInterfaceName, @RawInputDeviceInterfaceNameSize) < 0
		Debug "  > Error: Failed to properly query the device's interface name !"
		HasEncounteredAnError = #True
	EndIf
	
	; Getting the device's info
	Define RawInputDeviceInfo.RawInput::tagRID_DEVICE_INFO
	Define RawInputDeviceInfoSize = SizeOf(RawInput::tagRID_DEVICE_INFO)
	
	If RawInput::GetRawInputDeviceInfo(*RawInputDevice\hDevice, RawInput::#RIDI_DEVICEINFO,
	                                   @RawInputDeviceInfo, @RawInputDeviceInfoSize) < 0
		Debug "  > Error: Failed to properly query the device's info !"
		HasEncounteredAnError = #True
	EndIf
	
	; #RIDI_PREPARSEDDATA is not tested here.
	
	If HasEncounteredAnError
		; Data received is "unsafe" to process.
		Debug "  > Error: Unable to continue with this device !"
		Continue
	EndIf
	
	; Printing the device's info
	Debug "  > Interface name: "+RawInputDeviceInterfaceName
	
	Select RawInputDeviceInfo\dwType
		Case RawInput::#RIM_TYPEHID
			Debug "  > Device type: HID"
			Debug "  > Vendor ID: 0x"+RSet(Hex(RawInputDeviceInfo\hid\dwProductId), 4, "0")
			Debug "  > Product ID: 0x"+RSet(Hex(RawInputDeviceInfo\hid\dwVendorId), 4, "0")
			Debug "  > Version Nbr: 0x"+RSet(Hex(RawInputDeviceInfo\hid\dwVersionNumber), 4, "0")+
			      " | 0d"+Str(RawInputDeviceInfo\hid\dwVersionNumber)
			
			;usUsagePage and usUsage are not covered here !
		Case RawInput::#RIM_TYPEKEYBOARD
			Debug "  > Device type: Keyboard"
			
			Select RawInputDeviceInfo\keyboard\dwType
				Case RawInput::#RI_KEYBOARDTYPE_101
					; Same as #RI_KEYBOARDTYPE_102
					Debug "    > Keyboard type: Enhanced 101- or 102-key keyboards (and compatibles)"
				Case RawInput::#RI_KEYBOARDTYPE_JAPANESE
					Debug "    > Keyboard type: Japanese Keyboard"
				Case RawInput::#RI_KEYBOARDTYPE_KOREAN
					Debug "    > Keyboard type: Korean Keyboard"
				Case RawInput::#RI_KEYBOARDTYPE_UNKNOWN
					Debug "    > Keyboard type: Unknown type or HID keyboard"
				Default
					; Can easily be encountered with the "\\?\Microsoft Keyboard RID\..." devices !
					Debug "    > Keyboard type: Error (undocumented value/behaviour !)"
					Debug "      > 0d"+Str(RawInputDeviceInfo\keyboard\dwType)
					Debug "      > 0x"+RSet(Hex(RawInputDeviceInfo\keyboard\dwType), 8, "0")
			EndSelect
			
			Debug "    > Vendor sub-type: 0x"+RSet(Hex(RawInputDeviceInfo\keyboard\dwSubType), 8, "0")+
			      " | 0d"+Str(RawInputDeviceInfo\keyboard\dwSubType)
			
			Debug "    > Scan code Mode: "+Str(RawInputDeviceInfo\keyboard\dwKeyboardMode)
			Debug "    > Function key count: "+Str(RawInputDeviceInfo\keyboard\dwNumberOfFunctionKeys)
			Debug "    > LED indicator count: "+Str(RawInputDeviceInfo\keyboard\dwNumberOfIndicators)
			Debug "    > Total Key count: "+Str(RawInputDeviceInfo\keyboard\dwNumberOfKeysTotal)
		Case RawInput::#RIM_TYPEMOUSE
			Debug "  > Device type: Mouse"
			
			; May not properly reflect the mouse's abilities !
			Debug "    > Device ID properties: 0b"+RSet(Bin(RawInputDeviceInfo\mouse\dwId, #PB_Long), 4*8, "0")
			If RawInputDeviceInfo\mouse\dwId & RawInput::#MOUSE_HID_HARDWARE
				Debug "      > HID mouse"
			EndIf
			If RawInputDeviceInfo\mouse\dwId & RawInput::#WHEELMOUSE_HID_HARDWARE
				Debug "      > HID wheel mouse"
			EndIf
			If RawInputDeviceInfo\mouse\dwId & RawInput::#HORIZONTAL_WHEEL_PRESENT
				Debug "      > Mouse with horizontal wheel"
			EndIf
			; Ignoring some of the "undocumented" bit fields from: https://github.com/tpn/winsdk-10/blob/master/Include/10.0.16299.0/shared/ntddmou.h
			
			Debug "    > Button count: "+Str(RawInputDeviceInfo\mouse\dwNumberOfButtons)
			
			; This information may not be applicable for every mouse device.
			Debug "    > Data points per second: "+Str(RawInputDeviceInfo\mouse\dwSampleRate)
			
			If RawInputDeviceInfo\mouse\fHasHorizontalWheel
				Debug "    > Has horizontal wheel: True"
			Else
				Debug "    > Has horizontal wheel: False"
			EndIf
		Default
			Debug "  > Error: Unknown device type (undocumented behaviour !)"
			Debug "    > "+Str(RawInputDeviceInfo\dwType)
			Debug "    > 0x"+RSet(Hex(RawInputDeviceInfo\dwType), 16, "0")
			Continue
	EndSelect
Next

FreeMemory(*RawInputDeviceListBuffer)
