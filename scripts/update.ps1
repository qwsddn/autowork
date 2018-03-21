#version 1.2
#ip组输出内容如果觉得ip输出重复太多，可以将所有echo内容的$server去掉
param ($server,[int]$up_type,$d_path,$s_path,$psexec)
$ErrorActionPreference = "stop"
$today = Get-Date -UFormat "%Y%m%d"
$backup_name = "backup"
#这5个变量必须和rollback.ps1保持一致，否则回退可能会出现问题
$exclude1 = "log"
$exclude2 = "logs"
$exclude3 = "TMP"
$exclude4 = "TEMP"
$exclude5 = "FileTemp_SFTP"
$d_path1 = $d_path -replace ":","$"
$d_name = $d_path -replace ".*\\",""
$remote_path = "\\$server\$d_path1"
$big_size = [int]150
echo "$server update result:"
if(!(Test-Path $remote_path))
    {
    echo "$server update directory not exist."
    exit 1
    }
#backup
$backup_localpath = $d_path -replace "\\.*",""
$backup_localpath_name = $d_path -replace ".*\\",""
$backup_localfullname = "$backup_localpath\$backup_name\$today\$backup_localpath_name"
$d_path2 = ($d_path -replace ":.*","") + "$"
$backup_path = "\\$server\$d_path2\$backup_name\$today"
if(!(Test-Path $backup_path))
    {
    try
        {
        New-Item $backup_path -Type directory > $null
        }
    catch
        {
        echo "create backup directory failed."
        exit 1
        }
    }
$backup_res = "$backup_path\$d_name"
if(!(Test-Path $backup_res))
    {
    try
        {
        $d_size = (Get-ChildItem -recurse $remote_path |Measure-Object -Property length -sum).sum
        $d_size = [int]($d_size/1024/1024)
        if($d_size -le $big_size)
            {
            Copy-Item $remote_path $backup_path -Recurse -Force > $null
            if(Test-Path $backup_res)
                {
                echo "$server $d_path backup success."
                }
            }
        else
            {
            $count = 0
            #必须建这个备份目录,否则超过150M的第一个目录备份路径会有问题
            New-Item $backup_res -Type directory > $null
            foreach($temp_path in(Get-ChildItem $remote_path|ForEach-Object {$_.fullname}))
                {
                if((Get-Item $temp_path) -is [IO.fileinfo])
                    {
                    Copy-Item $temp_path $backup_res > $null
                    $count = $count + 1
                    }
                elseif((Get-Item $temp_path) -is [IO.directoryinfo])
                    {
                    $temp_path1 = $temp_path -replace ".*\\",""
                    if(($temp_path1 -ne $exclude1) -and ($temp_path1 -ne $exclude2) -and ($temp_path1 -ne $exclude3) `
                    -and ($temp_path1 -ne $exclude4) -and ($temp_path1 -ne $exclude5))
                        {
                        Copy-Item $temp_path $backup_res -Recurse -Force > $null
                        $count = $count + 1
                        }
                    }
                else
                    {
                    echo "backup unkown error."
                    Remove-Item $backup_res -Recurse -Force
                    exit 1
                    }
                }
            $count1 = [int]((Get-ChildItem $backup_res|Measure-Object -line).lines)
            if($count -eq $count1)
                {
                echo "$server $d_path big diretory backup success."
                }
            else
                {
                echo "$server $d_path big diretory backup failed."
                Remove-Item $backup_res -Recurse -Force
                exit 1
                }
            }
        }
    catch
        {
        echo "$server $d_path backup failed"
        Remove-Item $backup_res -Recurse -Force
        exit 1
        }
    }
else
    {
    echo "$server $backup_localfullname exist."
    }
#update
#website
if($up_type -eq 1)
    {
    try
        {
        foreach($temp_path2 in (Get-ChildItem $s_path|ForEach-Object {$_.fullname}))
            {
            Copy-Item $temp_path2 $remote_path -Recurse -Force > $null
            }
        echo "$server $d_path update success."
        }
    catch
        {
        echo "$server $d_path update failed."
        }
    }
#service
elseif($up_type -eq 2)
    {
    $ser_sta = cmd /c $psexec \\$server -nobanner -accepteula -s -n 10 cmd /c `
    "wmic service where 'pathname like '%$d_name%'' get name,state"
    if($ser_sta -match "Running")
        {
        foreach($servi in $ser_sta)
            {
            if($servi -match "Running" -and $servi -notmatch "^name")
                {
                try
                    {
                    $servi = ($servi -replace " Running","").Trim()
                    $stop_ser = cmd /c $psexec \\$server -nobanner -accepteula -s -n 10 net stop $servi
                    if($stop_ser -eq $null)
                        {
                        echo "$server stop $servi failed,update failed."
                        exit 1
                        }
                    echo "$server $stop_ser"
                    foreach($temp_path2 in (Get-ChildItem $s_path|ForEach-Object {$_.fullname}))
                        {
                        Copy-Item $temp_path2 $remote_path -Recurse -Force > $null
                        }
                    start-sleep 3
                    $start_ser = cmd /c $psexec \\$server -nobanner -accepteula -s -n 10 net start $servi
                    echo "$server $start_ser"
                    echo "$server $d_path update success."
                    }
               catch
                    {
                    echo "$server $d_path update failed."
                    }
                }
            }
        }
    elseif($ser_sta -match "Stopped")
        {
        try
            {
            foreach($temp_path2 in (Get-ChildItem $s_path|ForEach-Object {$_.fullname}))
                {
                Copy-Item $temp_path2 $remote_path -Recurse -Force > $null
                }
            echo "$server $d_path update success."
            }
        catch
            {
            echo "$server $d_path update failed."
            }
        }
    else
        {
        echo "$server $d_path not in service list or unknow error."
        }
    }


