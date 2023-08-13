$adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

$output = foreach ($adapter in $adapters) {
    $ipAddresses = $adapter.IPAddress | Where-Object { $_ -like "192.*" }
    $subnetMasks = $adapter.IPSubnet | Where-Object { $_ -like "255.*" }
    
    [PSCustomObject]@{
        "Adapter Description" = $adapter.Description
        "Adapter Index" = $adapter.Index
        "IP Address(es)" = $ipAddresses -join ", "
        "Subnet Mask(s)" = $subnetMasks -join ", "
        "DNS Domain Name" = $adapter.DNSDomain
        "DNS Server(s)" = $adapter.DNSServerSearchOrder -join ", "
    }
}

# $output | Format-Table -AutoSize

$output | Format-Table -AutoSize -Wrap -Property "Adapter Description", "Adapter Index", "IP Address(es)", "Subnet Mask(s)", "DNS Domain Name", "DNS Server(s)" | Out-String | Write-Host