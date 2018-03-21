$destination = $args[0]
$port = $args[1]
$timeout = 1500
if ("$port" -eq "ping")
{
	if ($(ping -n 2 -w 800 $destination) -match "$destination" | Measure-Object -Line | where-object { $_.Lines -le "2" })
	{
		return $false
	}
	else
	{
		return $true
	}
}
else
{
	try
	{
		$tcpclient = New-Object -TypeName system.Net.Sockets.TcpClient
		$iar = $tcpclient.BeginConnect($destination, $port, $null, $null)
		$wait = $iar.AsyncWaitHandle.WaitOne($timeout, $false)
		if (!$wait)
		{
			$tcpclient.Close()
			return $false
		}
		else
		{
			$null = $tcpclient.EndConnect($iar)
			$tcpclient.Close()
			return $true
		}
	}
	catch
	{
		$false
	}
}
