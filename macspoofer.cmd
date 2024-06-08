@echo off
title Batch Spoofer 1.2.0 - Developed By TechnicalUserX
	
cls
set interface_admin_state=Not Selected
set interface_registry_location=Not Selected
set interface_description=Not Selected
set interface_id=Not Selected
set interface_mac=Not Selected
set interface_state=notdefined
setlocal enabledelayedexpansion
mode con:cols=100 lines=30
set program_directory=%~dp0
set program_drive=!program_directory:~0,2!
%program_drive%
cd "%program_directory%"



:check_Permissions
	net session >nul 2>&1
	if %errorLevel% == 0 (
		set privilege_level=administrator
		cd !current_directory!
		cd BF_Files
		del attempt.xml >nul
		del infogate.xml >nul
		cls

	)else (
		set privilege_level=local
		cd BF_Files
		del attempt.xml >nul
		del infogate.xml >nul
		cls
	)
	
	if %privilege_level% neq administrator (
		echo.
		call :color_echo . red " Administrator Privileges required to use this program..."
		echo.
		timeout /t 3 >nul
		goto :exit_program
	)
	

	call :interface_detection
	
	
	if !interface_number!==1 (
		echo.
		call :color_echo . cyan " Interface Detection"
		echo.
		echo.
		call :color_echo . yellow " Only '1' Interface Found!"
		echo.
		echo.
		call :color_echo . white " !interface_1_description!("
		call :color_echo . magenta "!interface_1_mac!"
		call :color_echo . white ")"
		echo.
		echo.
		echo Making !interface_1_description! as default Interface...
		set interface_id=!interface_1_id!
		set interface_description=!interface_1_description!
		set interface_mac=!interface_1_mac!
		timeout /t 3 >nul
	)
	
	if !interface_number! gtr 1 (
		echo.
		call :color_echo . cyan " Interface Detection"
		echo.
		echo.
		call :color_echo . yellow " Multiple '!interface_number!' Interfaces Found!"
		echo.
		timeout /t 3 >nul
		call :interface_selection
	)
	
	if !interface_number!==0 (
		echo.
		call :color_echo . cyan " Interface Detection"	
		echo.
		echo.
		call :color_echo . yellow " WARNING"
		echo.
		echo  No interfaces found on this device^^!
		echo.
		echo  Press any key to continue...
		timeout /t 5 >nul
		cls
	)
	goto :interface_management	
	
	
	
	
	
	
	
	
	
:interface_management
	call :interface_admin_state_check
	call :interface_mac_check
	call :interface_registry_check
	:skip_interface_management_check
	cls
	echo.
	call :color_echo . cyan "Batch MAC Spoofer"
	echo.                                                             
	echo.
	call :color_echo . cyan "Description: "
	call :color_echo . yellow "!interface_description!
	echo.
	call :color_echo . cyan "MAC Address: "
	call :color_echo . magenta "!interface_mac!"
	echo.
	call :color_echo . cyan "MAC Address Status: "
	if "!interface_description!"=="Not Selected" (
		call :color_echo . white "Not Selected"
		goto :skip_mac_address_status_show
	)
	if "!interface_mac_changed!"=="true" (
		call :color_echo . red "Changed"
	)
	if !interface_mac_changed!==false (
		call :color_echo . green "Original Static Address"
	)
	:skip_mac_address_status_show
	echo.
	call :color_echo . cyan "ID: "
	call :color_echo . white "!interface_id!"
	echo.
	call :color_echo . cyan "Interface Status: "
	if "!interface_description!"=="Not Selected" (
		call :color_echo . white "Not Selected"
	)
	if !interface_admin_state!==Enabled (
		call :color_echo . green "Enabled"
	)
	if !interface_admin_state!==Disabled (
		call :color_echo . red "Disabled"
	)
	echo.
	echo.
	echo.
	call :color_echo . cyan "Interafe Management Commands"
	echo.
	echo.  
	echo  - select    : Choose another interface
	echo  - macspoof  : Perform MAC Spoofing (Administrator Privileges)
	echo  - exit      : Exits Interface Management
	echo.
	echo.
	
	
	call :userinput
	set /p interfacemanagementchoice=
	
	if "!interfacemanagementchoice!"=="exit" (
		exit
	)
	
	if "!interfacemanagementchoice!"=="select" (
		call :interface_detection
		call :interface_selection
		cls
		set interfacemanagementchoice=
		goto :interface_management
		
	)
	
	
	if "!interfacemanagementchoice!"=="macspoof" (
		if "!interface_description!"=="Not Selected" (
			echo.
			call :color_echo . red " An Interface must be selected for MAC Spoofing..."
			timeout /t 3 >nul
			set interfacemanagementchoice=
			cls
			goto :skip_interface_management_check
		
		)
		
		call :mac_spoofing
		set interfacemanagementchoice=
		cls
		goto :skip_interface_management_check
	
	)
	
	
	call :color_echo . red " Invalid input"
	echo.
	timeout /t 2 >nul
	cls
	set interfacemanagementchoice=
	goto :skip_interface_management_check




:mac_spoofing
	
	if "!privilege_level!"=="local" (
		echo.
		call :color_echo . red " Administrator Privileges required to use this feature..."
		timeout /t 3 >nul
		cls
		set interfacemanagementchoice=
		goto :skip_interface_management_check
	)
	cls
	echo.
	call :color_echo . cyan " MAC Spoofing"
	echo.
	echo.
	call :color_echo . cyan "   Interface: "
	call :color_echo . yellow "!interface_description!"
	echo.
	call :color_echo . cyan "   MAC: "
	call :color_echo . yellow "!interface_mac!"
	echo.
	echo.
	call :color_echo . cyan "    MAC Spoofing Commands"
	echo.
	echo.
	echo  - revert           : Revert MAC address to original
	echo  - randomize mac    : Randomize MAC Address
	echo  - define mac       : Set MAC Manually
	echo  - exit             : Exit MAC Spoofing screen
	echo.
	echo.
	
	call :userinput
	set /p macspoofingchoice=
	
	if "!macspoofingchoice!"=="exit" (
		set macspoofingchoice=
		cls
		goto :eof
	
	)
	
	
	if "!macspoofingchoice!"=="revert" (
		
		if !interface_mac_changed!==false (
			echo.
			call :color_echo . red " !interface_description! is already has Original Static MAC..."
			timeout /t 3 >nul
			set macspoofingchoice=
			cls
			goto :mac_spoofing
		)
		echo.
		echo Disabling "!interface_description!"...
		netsh interface set interface name="!interface_id!" admin=disabled >nul
		echo Reverting MAC Address...
		reg delete !interface_registry_location! /v NetworkAddress /f >nul
		echo Enabling "!interface_description!"...
		netsh interface set interface name="!interface_id!" admin=enabled >nul
		call :color_echo . green " Completed"
		timeout /t 3 >nul
		set macspoofingchoice=
		cls
		goto :interface_management
	
	)
	
	if "!macspoofingchoice!"=="define mac" (
		set allowed_mac_char_list_obliged=EA26
		set allowed_mac_char_list=0123456789ABCDEF
		cls
		echo.
		echo Type the MAC without semicolons
		echo.
		call :color_echo . white "   Example format: "
		call :color_echo . green "AABBCCDDEEFF"
		echo.
		call :color_echo . yellow "   WARNING: Second character of the MAC should be one of these {E, A, 2, 6 }
		echo.
		call :color_echo . red "   This is a Windows restriction"
		echo.
		echo.
		call :userinput
		set /p manual_mac=
	
		call :create_string manual_mac_check "!manual_mac!"
		
		if  !manual_mac_check_length! neq 12 (
			call :color_echo . red " Length of a MAC must be 12 characters."
			timeout /t 3 >nul
			set macspoofingchoice=
			cls
			goto :interface_management	
		)
		
		
		
		for /l %%a in ( 0, 1, 11) do (
			
			if "%%a" == "1" (
			
				if "!manual_mac_check:~%%a,1!" neq "E" if "!manual_mac_check:~%%a,1!" neq "e" if "!manual_mac_check:~%%a,1!" neq "A" if "!manual_mac_check:~%%a,1!" neq "a" if "!manual_mac_check:~%%a,1!" neq "6" if "!manual_mac_check:~%%a,1!" neq "2" (
					call :color_echo . red " Second character is not matching the criteria, please use E, A, 2, or 6
					timeout /t 3 >nul
					set macspoofingchoice=
					cls
					goto :interface_management				
				)

			)
		
			call :validate_mac_char "!manual_mac_check:~%%a,1!"
			if "!valid!" == "false" (
				call :color_echo . red " Invalid character has been used"
				timeout /t 3 >nul
				set macspoofingchoice=
				cls
				goto :interface_management	
			)
		
		
		)
		echo.
		call :color_echo . white " Defined MAC: "
		call :color_echo . green "!manual_mac!"
		echo.

		echo.
		echo Disabling "!interface_description!"...
		netsh interface set interface name="!interface_id!" admin=disabled >nul	
		echo Applying new MAC Address...
		reg add !interface_registry_location! /v NetworkAddress /t REG_SZ /d "!manual_mac!" /f 
		echo Enabling "!interface_description!"...
		netsh interface set interface name="!interface_id!" admin=enabled >nul
		call :color_echo . green " Completed"


		timeout /t 3 >nul
		set macspoofingchoice=
		cls
		goto :interface_management	
	)
	
	
	
	
	if "!macspoofingchoice!"=="randomize mac" (
		echo.
		echo Generating a random MAC Address...
		
		call :mac_randomizer
		echo.
		call :color_echo . white " Generated: "
		call :color_echo . green "!set_mac!"
		echo.
		echo Disabling "!interface_description!"...
		netsh interface set interface name="!interface_id!" admin=disabled >nul	
		echo Applying new MAC Address...
		reg add !interface_registry_location! /v NetworkAddress /t REG_SZ /d "!set_mac!" /f
		echo Enabling "!interface_description!"...
		netsh interface set interface name="!interface_id!" admin=enabled >nul
		call :color_echo . green " Completed"
		timeout /t 3 >nul
		set macspoofingchoice=
		cls
		goto :interface_management
	)
	

	
	echo.
	call :color_echo . red " Invalid input"
	echo.
	timeout /t 2 >nul
	set macspoofingchoice=
	cls
	goto :mac_spoofing
	

	
:interface_selection
	call :interface_detection
	set interface_choice=
	del interfacelist.txt 2>nul
	cls
	echo.
	set temp_interface_num_for_selection=1
	call :color_echo . cyan " Interface Selection"
	echo.
	echo.
	for /l %%a in ( 1, 1, !interface_number! ) do (
		
		call :color_echo . yellow " !temp_interface_num_for_selection! - "
		call :color_echo . white "!interface_%%a_description!("
		call :color_echo . magenta "!interface_%%a_mac!"
		call :color_echo . white ")"
		echo.
		
		echo !temp_interface_num_for_selection! - !interface_%%a_description! - !interface_%%a_mac!>>interfacelist.txt
		
		set /a temp_interface_num_for_selection=!temp_interface_num_for_selection!+1
	)
	call :color_echo . red " !temp_interface_num_for_selection! - "
	call :color_echo . white "Cancel Selection"
	echo.
	echo !temp_interface_num_for_selection! - Cancel Selection>>interfacelist.txt
	set choice_cancel=!temp_interface_num_for_selection!
	
	echo.
	call :userinput
	set /p interface_choice=
	
	if !interface_choice!==!choice_cancel! (
		goto :eof
	)

	if !interface_choice! gtr !interface_number! ( 
		call :color_echo . red " Invalid input"
		echo.
		timeout /t 2 >nul
		cls
		set interface_choice=
		goto :interface_selection
	)

	if !interface_choice! lss 1 ( 
		call :color_echo . red " Invalid input"
		echo.
		timeout /t 2 >nul
		cls
		set interface_choice=
		goto :interface_selection
	)
	
	
	for /f "tokens=1-3" %%a in ( interfacelist.txt ) do (
	
		if !interface_choice!==%%a (
			echo.
			echo.
			
			set interface_id=!interface_%%a_id!
			set interface_description=!interface_%%a_description!
			set interface_mac=!interface_%%a_mac!
			set targetwifi=No WI-FI Selected
			
			
			call :color_echo . white " Setting "
			call :color_echo . yellow "!interface_description! "
			call :color_echo . /f " as current interface..."
			timeout /t 3 >nul
		
		)
	
	)
	
	cls
	del interfacelist.txt
	goto :eof		
	

:interface_detection
	set interface_number=0
	
	for /f "tokens=1-4" %%a in ('netsh wlan show interfaces ^| findstr /L "Name Description Physical"') do (
		if "%%c"=="Wi-Fi" (
		
			if "%%d"=="" (
			set /a interface_number=!interface_number!+1
			set interface_!interface_number!_id=%%c
			)else (
			set /a interface_number=!interface_number!+1
			set interface_!interface_number!_id=%%c %%d
			)
		

		)
		if %%a==Description (
			set interface_!interface_number!_description=%%c %%d
		)
		if %%a==Physical (
			set interface_!interface_number!_mac=%%d
		)	
	)
	goto :eof
	

:interface_admin_state_check
	for /f "tokens=1-5" %%a in ( ' netsh interface show interface name^="!interface_id!" ' ) do (
		if %%a==Administrative (
			set interface_admin_state=%%c
			goto :eof
		)
	)
	goto :eof
	
	
	
	
	
:interface_mac_check 
	for /f "tokens=1-4" %%a in ( 'wmic nic get name^,macaddress ^| findstr /L "!interface_description!"') do (
		if "!interface_description!"=="%%b %%c" (
		set interface_mac=%%a
		goto :eof
		)
		
	)
	goto :eof
	
	
	
	
	
	
:interface_registry_check
	for /f "tokens=* skip=8" %%a in ( 'REG QUERY HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}' ) do (
		set current_registry_key=%%a
		set current_registry_interface_description=
		set interface_mac_changed=false
		
		for /f "tokens=1-10" %%b in ( 'REG QUERY !current_registry_key! 2^>nul' ) do (
		
			if %%b==DriverDesc (
				set current_registry_interface_description=%%d %%e
			)
			
			if %%b==NetworkAddress (
				set interface_mac_changed=true
			)
			
		)

		if "!interface_description!" equ "!current_registry_interface_description!" (
			set interface_registry_location=!current_registry_key!
			goto :eof
		)
	)
	
	goto :eof
	

:userinput
	call :color_echo . green " macspoofer"
	call :color_echo . white "$ "

	goto :eof
	
	
:mac_randomizer
	set allowed_mac_char_list_obliged=EA26
	set allowed_mac_char_list=0123456789ABCDEF
	set set_mac=
	
	for /l %%a in ( 1,1,12) do (
	
		if %%a==2 (
			call :index_for_mac_calc_2
			call :set_mac_char_2 !index_for_mac!
		)else (	
			call :index_for_mac_calc_1
			call :set_mac_char_1 !index_for_mac!	
		)
	) 
	goto :eof
	:index_for_mac_calc_1
		set /a index_for_mac=(!random!) %% 16
	goto :eof
	:set_mac_char_1
		set set_mac=!set_mac!!allowed_mac_char_list:~%1,1!
	goto :eof
	:index_for_mac_calc_2
		set /a index_for_mac=(!random!) %% 4
	goto :eof
	:set_mac_char_2
		set set_mac=!set_mac!!allowed_mac_char_list_obliged:~%1,1!
	goto :eof
	
	
	
:create_string
	set /a takeaway=4
	set string=%2
	echo !string!>var.txt
	
	for /f "useback tokens=*" %%a in ( '%string%' ) do (
		if !string!==%%~a (
			set /a takeaway=2
		)
	
		set string=%%~a 
	
	)
	set %1=!string!
	
	for %%I in ( var.txt ) do (
		set /a %1_length=%%~zI - !takeaway!
	)
	del var.txt
	goto :eof
	
	
:validate_mac_char
	set allowed_mac_char_list_obliged_extended=EA26ea
	set allowed_mac_char_list_extended=0123456789ABCDEFabcdef
	set valid=false
	
	for /l %%a in ( 0, 1, 21) do (
		if  "%~1" == "!allowed_mac_char_list_extended:~%%a,1!" (
			set valid=true
			goto :eof
		)
	
	
	)
	goto :eof
	

:color_echo 

    :: Check if the first 2 arguments are empty, cause they are needed for background/foreground information
    :: The 3rd argument is not that important because it can be an empty string
    if "%~1" equ "" (
        goto :eof
    )
    if "%~2" equ "" (
        goto :eof
    )

    :: Background color; if invalid, no action
    if "%~1" equ "black" (
        <nul set /p=[40m
    )

    if "%~1" equ "red" (
        <nul set /p=[41m
    )

    if "%~1" equ "green" (
        <nul set /p=[42m
    )

    if "%~1" equ "yellow" (
        <nul set /p=[43m
    )

    if "%~1" equ "blue" (
        <nul set /p=[44m
    )

    if "%~1" equ "magenta" (
        <nul set /p=[45m
    )

    if "%~1" equ "cyan" (
        <nul set /p=[46m
    )

    if "%~1" equ "white" (
        <nul set /p=[47m
    )

    :: Foreground color; if invalid, no action

    if "%~2" equ "black" (
        <nul set /p=[30m
    )

    if "%~2" equ "red" (
        <nul set /p=[31m
    )

    if "%~2" equ "green" (
        <nul set /p=[32m
    )

    if "%~2" equ "yellow" (
        <nul set /p=[33m
    )

    if "%~2" equ "blue" (
        <nul set /p=[34m
    )

    if "%~2" equ "magenta" (
        <nul set /p=[35m
    )

    if "%~2" equ "cyan" (
        <nul set /p=[36m
    )

    if "%~2" equ "white" (
        <nul set /p=[37m
    )

    <nul set /p="%~3" <nul
    <nul set /p=[0m

	goto :eof



:exit_program
	goto :eof


