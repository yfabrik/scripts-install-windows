# scripts pour auto install windows

## sur clé usb
install ventoy en laissant un espace (18GO mini)
format l'espace en exFAT le nommer SPACE
dans space mettre le repo dans un dossier scripts
et les images custom famille.wim/bureau.wim
dans ventoy faut utiliser le plugin injection
faire une archive .7z avec l'arborecense
windows
  |_ system32
    |_ startnet.cmd

```
::startnet.cmd
wpeinit
for %%a in (d e f g h i j k l m n o p q r s t u v w x y z) do @vol %%a: 2>nul |find "SPACE" >nul && set drv=%%a:
call %drv%\scripts\auto-install.bat %drv%\bureau.wim
call %drv%\cp-files.bat
```
pour install bureau.wim

```
::startnet.cmd
wpeinit
for %%a in (d e f g h i j k l m n o p q r s t u v w x y z) do @vol %%a: 2>nul |find "SPACE" >nul && set drv=%%a:
call %drv%\scripts\auto-install.bat %drv%\famille.wim
copy /y %drv%\files\unattend.xml W:\Windows\System32\Sysprep\unattend.xml
```
pour famille

faudra aussi faire des copie de winPE dans la partition ventoy pour chaque image, parce que j'ai pas trouvé pour utiliser 1 iso pour plusieurs injections

## avec serveur pxe
sur le srv samba du serveur 
y'a le fichier winpeshl.ini
```
[launchApps]
"install.bat"
```
qui sert a lancer les install.bat
bureau:
```
wpeinit
net use Y: \\srvpxe\install
call Y:\scripts\external\auto-install.bat Y:\disks\win.wim.d\capture-withapp.wim
call Y:\scripts\external\cp-files.bat
```

famille: 
```
wpeinit
net use Y: \\srvpxe\install
call Y:\scripts\external\auto-install.bat Y:\disks\win.wim.d\famille.wim
copy /y Y:\scripts\external\autounattend.xml W:\windows\system32\sysprep\unattend.xml
```

et apres c'est les memes scripts que sur SPACE
faut juste les mettre au bons endroits
