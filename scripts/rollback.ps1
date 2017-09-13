#version 1.2
$ErrorActionPreference = "stop"
$today = Get-Date -UFormat "%Y%m%d"
$backup_name = "backup"
#这5个变量必须和update.ps1保持一致，否则回退可能会出现问题
$exclude1 = "log"
$exclude2 = "logs"
$exclude3 = "TMP"
$exclude4 = "TEMP"
$exclude5 = "FileTemp_SFTP"
#rollback
$d_path1 = $d_path -replace ":","$"
$d_name = $d_path -replace ".*\\",""
$remote_path = "\\$server\$d_path1"
echo "$server rollback result:"
if(!(Test-Path $remote_path))
    {
    echo "$server rollback destination directory not exist."
    exit 1
    }
$d_path2 = ($d_path -replace ":.*","") + "$"
$backup_path = "\\$server\$d_path2\$backup_name\$today"
$backup_res = "$backup_path\$d_name"
$backup_localpath = $d_path -replace "\\.*",""
$backup_localres = "$backup_localpath\$backup_name\$today\$d_name"
if(Test-Path $backup_res)
    {
    #website
    if($ro_type -eq 1)
        {
        try
            {
            $count = ($d_path |% {$_.split('\')}).count
            $count1 = 0
            foreach($rb_path in ($d_path.split('\')))
                {
                $count1 = $count1 + 1
                $rb_path1 = $rb_path1 + $rb_path + "\"
                if($count1 -eq ($count-1))
                    {
                    break
                    }
                 }
            $rb_path1 = $rb_path1 -replace ":","$"
            $rb_path1 = "\\$server\$rb_path1"
            #删除程序目录下除了日志目录的所有其他文件
			foreach ($temp_path in (Get-ChildItem $remote_path | ForEach-Object { $_.fullname }))
			    {
				if ((Get-Item $temp_path) -is [IO.fileinfo])
				    {
					Remove-Item -Force -Recurse $temp_path > $null
				    }
				elseif ((Get-Item $temp_path) -is [IO.directoryinfo])
				    {
					$temp_path1 = $temp_path -replace ".*\\", ""
					if (($temp_path1 -ne $exclude1) -and ($temp_path1 -ne $exclude2) -and ($temp_path1 -ne $exclude3) `
                    -and ($temp_path1 -ne $exclude4) -and ($temp_path1 -ne $exclude5))
					    {
						Remove-Item -Force -Recurse $temp_path > $null
					    }
				    }
			    }
			Copy-Item $backup_res $rb_path1 -Recurse -Force > $null
            echo "$server rollback success."
            }
        catch
            {
            echo "$server rollback failed."
            }
        }
    #service
    elseif($ro_type -eq 2)
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
                            echo "$server stop $servi failed,rollback failed."
                            exit 1
                            }
                        echo "$server $stop_ser"
                        $count = ($d_path |% {$_.split('\')}).count
                        $count1 = 0
                        foreach($rb_path in ($d_path.split('\')))
                            {
                                $count1 = $count1 + 1
                                $rb_path1 = $rb_path1 + $rb_path + "\"
                                if($count1 -eq ($count-1))
                                    {
                                    break
                                    }
                            }
                        $rb_path1 = $rb_path1 -replace ":","$"
                        $rb_path1 = "\\$server\$rb_path1"
						foreach ($temp_path in (Get-ChildItem $remote_path | ForEach-Object { $_.fullname }))
						    {
							if ((Get-Item $temp_path) -is [IO.fileinfo])
							    {
								Remove-Item -Force -Recurse $temp_path > $null
							    }
							elseif ((Get-Item $temp_path) -is [IO.directoryinfo])
							    {
								$temp_path1 = $temp_path -replace ".*\\", ""
								if (($temp_path1 -ne $exclude1) -and ($temp_path1 -ne $exclude2) -and ($temp_path1 -ne $exclude3) `
                                -and ($temp_path1 -ne $exclude4) -and ($temp_path1 -ne $exclude5))
								    {
									Remove-Item -Force -Recurse $temp_path > $null
								    }
							    }
						    }
						Copy-Item $backup_res $rb_path1 -Recurse -Force > $null
                        $start_ser = cmd /c $psexec \\$server -nobanner -accepteula -s -n 10 net start $servi
                        echo "$server $start_ser"
                        echo "$server $d_path rollback success."
                        }
                    catch
                        {
                        echo "$server $d_path rollback failed."
                        }
                    }
                }
            }
        elseif($ser_sta -match "Stopped")
            {
            try
                {
                $count = ($d_path |% {$_.split('\')}).count
                $count1 = 0
                foreach($rb_path in ($d_path.split('\')))
                    {
                    $count1 = $count1 + 1
                    $rb_path1 = $rb_path1 + $rb_path + "\"
                    if($count1 -eq ($count-1))
                         {
                         break
                         }
                    }
                $rb_path1 = $rb_path1 -replace ":","$"
                $rb_path1 = "\\$server\$rb_path1"
                foreach ($temp_path in (Get-ChildItem $remote_path | ForEach-Object { $_.fullname }))
				    {
					if ((Get-Item $temp_path) -is [IO.fileinfo])
						{
						Remove-Item -Force -Recurse $temp_path > $null
						}
					elseif ((Get-Item $temp_path) -is [IO.directoryinfo])
						{
						$temp_path1 = $temp_path -replace ".*\\", ""
						if (($temp_path1 -ne $exclude1) -and ($temp_path1 -ne $exclude2) -and ($temp_path1 -ne $exclude3) `
                        -and ($temp_path1 -ne $exclude4) -and ($temp_path1 -ne $exclude5))
							{
							Remove-Item -Force -Recurse $temp_path > $null
							}
						}
					}
                Copy-Item $backup_res $rb_path1 -Recurse -Force > $null
                echo "$server $d_path rollback success."
                }
            catch
                {
                echo "$server $d_path rollback failed."
                }
            }
        else
            {
            echo "$server $d_path rollback unkown error."
            }
        }
    }
else
    {
    echo "$server $backup_localres not exist."
    exit 1
    }

