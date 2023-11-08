on capture les images bureau et famille avec dism /capture-image
mount une des 2 avec dism /mount-image
on ajoute l'image monté à l'autre .wim avec 
`DISM.exe /Append-Image /ImageFile:<path_to_image_file> /CaptureDir:<source_directory> /Name:<image_name> [/Description:<image_description>] [/ConfigFile:<configuration_file.ini>] [/Bootable] /WIMBoot [/CheckIntegrity] [/Verify] [/NoRpFix]`
