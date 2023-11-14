# scripts pour auto install windows

## sur clé usb
installer ventoy en laissant un espace (18GO mini)  
formatter l'espace en exFAT le nommer SPACE  
on a 3 partition: SPACE, VENTOY, VENTOYEFI, on touche pas à VENTOYEFI  
dans SPACE :
-  mettre le repo (```git clone https://github.com/yfabrik/scripts-install-windows```)  
-  les images custom famille.wim/bureau.wim  


dans VENTOY :
- les images ISO winPE (1 image winPE (la meme, juste un copie colle avec un nom different) pour chaque image custom, parce que j'ai pas trouvé comment faire autrement)
- archives .7z (1 pour famille.wim 1, pour bureau.wim) avec arborescence:
```
windows
  |_ system32
    |_ startnet.cmd

```
contenu du starnet.cmd pour bureau.wim:
```
::startnet.cmd
wpeinit
for %%a in (d e f g h i j k l m n o p q r s t u v w x y z) do @vol %%a: 2>nul |find "SPACE" >nul && set drv=%%a:
call %drv%\scripts\auto-install.bat %drv%\bureau.wim
call %drv%\cp-files.bat
```

pour famille.wim:
```
::startnet.cmd
wpeinit
for %%a in (d e f g h i j k l m n o p q r s t u v w x y z) do @vol %%a: 2>nul |find "SPACE" >nul && set drv=%%a:
call %drv%\scripts\auto-install.bat %drv%\famille.wim
copy /y %drv%\files\unattend.xml W:\Windows\System32\Sysprep\unattend.xml
```

Ventoy a un plugin pour injecter des fichiers dans l'os choisi  
lancer ventoyplugson.sh en lui donnant l'emplacement de la clé USB (``sudo ./VentoyPlugson.sh /dev/sdb``)  
utiliser le injection plugin et lier le winpe_bureau au bureau.7z et le winpe_famille au famille.7z  


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

nouvelle façon:
on peut utiliser le install.bat qu'on rename en startnet.cmd dans le install.ipxe

```
:bureau
initrd --name startnet.cmd ${scripts}/startnet-bureau.cmd startnet.cmd
goto massdriver

```