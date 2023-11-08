@echo copy unattend xml pour auto init le user
copy /y %~dp0\files\unattend.xml W:\Windows\System32\Sysprep\unattend.xml
@echo copy layoutmodification pour clean menu demarrer et taskbar
copy /y %~dp0\files\LayoutModification.xml W:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml

@echo set app association
Dism /Image:W:\ /Import-DefaultAppAssociations:%~dp0\files\AppAssoc.xml

@echo post install script
copy /y %~dp0\files\post-install.bat W:\Windows\System32\Sysprep\post-install.bat
