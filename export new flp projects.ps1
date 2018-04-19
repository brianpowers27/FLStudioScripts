
$WorkingDirectory='H:\Program Files (x86)\Image-Line\FL Studio 12\Data\Projects\bdp'

# for each file in directory
$files = Get-ChildItem $WorkingDirectory -Filter *.flp 
$TempFolder = 'H:\Program Files (x86)\Image-Line\FL Studio 12\Data\Projects\bdp\renderTemp'
$GoogleDriveFolder = 'C:\Users\brian\Google Drive\FL Studio Song Share\SongsByBDP'

# try to create the subdirectory
Remove-Item –path $TempFolder –recurse #clean old
New-Item -ItemType Directory -Force -Path $TempFolder


foreach($file in $files) {

    # Set project name
    $flpFilePath = $file.FullName
    $flpProjectName= $file.BaseName

    # get project export time
    $projectWritedate = $file.LastWriteTime
	    
    # build mp3 file name
    $mp3FilePath = $WorkingDirectory+"\"+$flpProjectName+".mp3"

    # get mp3 export time
    $mp3File = Get-ItemProperty -Path $mp3FilePath -Name LastWriteTime -ErrorAction SilentlyContinue

    try{$mp3Writedate = ($mp3File.LastWriteTime).AddMinutes(20)} 
    catch
    {
        # no mp3 found, always write.
        $mp3Writedate= Get-Date 
        $mp3Writedate=$mp3Writedate.AddDays(-7000)
    }
    
    
    # if wave time less than mp3 -  export
    if($mp3Writedate -le $projectWritedate)
    {
		Copy-Item $flpFilePath $TempFolder
        "         Rendering --------------->"+$flpProjectName+" -- Process FLP file"
        $commandToExecute= '"H:\Program Files (x86)\Image-Line\FL Studio 12\FL64.exe" /R /Emp3 /F"'+$TempFolder+'"'
        $argumentList= '/R /Emp3 /F"'+$TempFolder+'"'
        $processToExecute= '"H:\Program Files (x86)\Image-Line\FL Studio 12\FL.exe" /R /Emp3 /F"'+$TempFolder+'"' # was fl64

        # & $CMD $arg1 $arg2 $arg3 $arg4
        $p = Start-Process $processToExecute -ArgumentList $argumentList  -wait -NoNewWindow -PassThru
        # $p.HasExited
        # $p.ExitCode

        #Copy to work dir
        $newFileTemp = $TempFolder+"\"+$flpProjectName+".mp3"
        Copy-Item $newFileTemp $WorkingDirectory
        "      --Item Copied from "+$newFile
        "      to " +$WorkingDirectory+"\n"
        "--"
        ""

        #Copy to Google Drive
        $newFileGoogleDrive = $GoogleDriveFolder+"\"+$flpProjectName+".mp3"
        
        Copy-Item $newFileTemp $GoogleDriveFolder -force
        "      --Item Copied from "+$newFile
        "      to " +$GoogleDriveFolder+"\n"
        "--"
        ""

        $TempFolderFile = $TempFolder+"\*"
        Remove-Item –path $TempFolderFile
    } 
    else
    {
        " ---------"+$flpProjectName+ " -- Skipping  - FLP file is already up to date"        
    }
	

}





