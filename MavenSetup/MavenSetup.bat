:: get password
:: Ensure maven is installed and environmental variables have been set
:: Ensure %UserProfile%/.m2 dir exists
:: Ensure settings.xml and settings-security.xml exists
:: run maven command for master and normal password
:: Add both in users/afid/.m2/settings and security files


@echo Off
setlocal EnableDelayedExpansion
set /p afid=Enter your AF ID: 
set /p pass=Enter your password: 

SET mypath=%~dp0

for /f %%i in ('mvn --encrypt-master-password %pass%') do set masterencryptedpass=%%i
for /f %%i in ('mvn --encrypt-password %pass%') do set encryptedpass=%%i

:: echo Your encrypted password is %encryptedpass%
:: echo Your encrypted master password is %masterencryptedpass%

cd %UserProfile%
if not exist %UserProfile%/.m2 mkdir .m2

(for /F "delims=" %%a in (%mypath:~0,-1%/settings.xml) do (
   set "line=%%a"
   set "newLine=!line:<password>=!"
   if "!newLine!" neq "!line!" (
		set "newLine=			<password>%encryptedpass%</password>"
    ) else (
		set "newLine=!line:<username>=!"
		if "!newLine!" neq "!line!" (
			set "newLine=			<username>%afid%</username>"
		)
	)
	echo !newLine!
)) > settings.xml.new
move /y "settings.xml.new" "%UserProfile%/.m2/settings.xml"

(for /F "delims=" %%a in (%mypath:~0,-1%/settings-security.xml) do (
   set "line=%%a"
   set "newLine=!line:<master>=!"
   if "!newLine!" neq "!line!" (
      set "newLine=	<master>%masterencryptedpass%</master>"
   )
   echo !newLine!
)) > settings-security.xml.new
move /y "settings-security.xml.new" "%UserProfile%/.m2/settings-security.xml"

if !encryptedpass! == '[ERROR]' goto error
if !encryptedpass! == '[FATAL]' goto error
if !masterencryptedpass! == '[ERROR]' goto error
if !masterencryptedpass! == '[FATAL]' goto error

echo settings.xml and settings-security.xml successfully modified with encrypted passwords
goto end

:error
echo Error while creating password, please re-run the batch files

:end
pause;