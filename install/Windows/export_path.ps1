param (
    [string]$dir = ""
)

Function global:ADD-PATH()
{
    [Cmdletbinding()]
    param
    (
    [parameter(Mandatory=$True,
    ValueFromPipeline=$True,
    Position=0)]
    [String[]]$AddedFolder
    )

    # System PATH
    #$EnvironmentKey = 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment'

    # User PATH
    $EnvironmentKey = 'Registry::HKEY_CURRENT_USER\Environment'

    # Get the current search path from the environment keys in the registry.

    $OldPath=(Get-ItemProperty -Path $EnvironmentKey -Name PATH).Path

    # See if a new folder has been supplied.

    IF (!$AddedFolder)
    { Return ‘No Folder Supplied. $ENV:PATH Unchanged’}

    # See if the new folder exists on the file system.

    IF (!(TEST-PATH $AddedFolder))
    { Return ‘Folder Does not Exist, Cannot be added to $ENV:PATH’ }

    # See if the new Folder is already in the path.

    IF ($ENV:PATH | Select-String -SimpleMatch $AddedFolder)
    { Return ‘Folder already within $ENV:PATH' }

    # Set the New Path

    $NewPath=$OldPath+’;’+$AddedFolder

    Set-ItemProperty -Path $EnvironmentKey -Name PATH –Value $newPath

    # Show our results back to the world

    Return $NewPath
}

FUNCTION GLOBAL:GET-PATH()
{
    Return $ENV:PATH
}

Function global:REMOVE-PATH()
{
    [Cmdletbinding()]
    param
    (
    [parameter(Mandatory=$True,
    ValueFromPipeline=$True,
    Position=0)]
    [String[]]$RemovedFolder
    )

    # System PATH
    #$EnvironmentKey = 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment'

    # User PATH
    $EnvironmentKey = 'Registry::HKEY_CURRENT_USER\Environment'

    # Get the Current Search Path from the environment keys in the registry

    $NewPath=(Get-ItemProperty -Path $EnvironmentKey -Name PATH).Path

    # Find the value to remove, replace it with $NULL. If it’s not found, nothing will change.

    $NewPath=$NewPath –replace $RemovedFolder,$NULL

    # Update the Environment Path

    Set-ItemProperty -Path $EnvironmentKey -Name PATH –Value $newPath

    # Show what we just did

    Return $NewPath
}

ADD-PATH($dir)