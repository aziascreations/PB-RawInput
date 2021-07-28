# PB-RawInput
A module to access and use Windows' RawInput API.

## Usage
Simply include "*[RawInput.pbi](Includes/RawInput.pbi)*" and use the structures, functions and datatypes documented on the [MSDN page](https://docs.microsoft.com/en-us/windows/win32/inputdev/raw-input.) with the `RawInput::` prefix.

## Considerations
* The module has not been tested on x86 platforms
* Some structure fields may not be available on Windows XP, see Microsoft's documentation.
* `GetRawInputDeviceInfoA` and `GetRawInputDeviceInfoW` are available under `GetRawInputDeviceInfo`.

## Useful Links
* MSDN page - https://docs.microsoft.com/en-us/windows/win32/inputdev/raw-input
* MSDN page - https://docs.microsoft.com/en-us/windows/win32/inputdev/raw-input

## License
[Unlicense](LICENSE)
