
function Get-ComputerSystem {
    return Get-CimInstance -Class Win32_ComputerSystem
}

function Get-OperatingSystem {
    return Get-CimInstance -Class Win32_OperatingSystem
}

function Get-Processor {
    return Get-CimInstance -Class Win32_Processor
}

function Get-PhysicalMemory {
    return Get-CimInstance -Class Win32_PhysicalMemory | Select-Object -Property BankLabel, DeviceLocator, Manufacturer, Capacity
}

function Get-LogicalDisks {
    $diskDrives = Get-CimInstance -Class Win32_DiskDrive
    $logicalDisks = foreach ($disk in $diskDrives) {
        $partitions = $disk | Get-CimAssociatedInstance -ResultClassName Win32_DiskPartition
        foreach ($partition in $partitions) {
            Get-CimAssociatedInstance -InputObject $partition -ResultClassName Win32_LogicalDisk
        }
    }
    return $logicalDisks | Select-Object -Property SystemName, VolumeName, Size, FreeSpace, @{Name="% Free";Expression={"{0:P2}" -f ($_.FreeSpace / $_.Size)}} 
}

function Get-NetworkAdapters {
    $adapters = Get-CimInstance -Class Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq $true}
    $report = foreach ($adapter in $adapters) {
        $ipAddresses = $adapter.IPAddress -join ", "
        $subnetMasks = $adapter.IPSubnet -join ", "
        $dnsServers = $adapter.DNSServerSearchOrder -join ", "
        $dnsDomain = $adapter.DNSDomain

        [PSCustomObject]@{
            Description = $adapter.Description
            Index = $adapter.Index
            IPAddress = if ($ipAddresses) {$ipAddresses} else {"N/A"}
            SubnetMask = if ($subnetMasks) {$subnetMasks} else {"N/A"}
            DNSDomain = if ($dnsDomain) {$dnsDomain} else {"N/A"}
            DNSServer = if ($dnsServers) {$dnsServers} else {"N/A"}
        }
    }
    return $report
}

function Get-VideoController {
    return Get-CimInstance -Class Win32_VideoController | Select-Object -Property AdapterCompatibility, Caption, CurrentHorizontalResolution, CurrentVerticalResolution
}

$computerSystem = Get-ComputerSystem
$operatingSystem = Get-OperatingSystem
$processor = Get-Processor
$physicalMemory = Get-PhysicalMemory
$logicalDisks = Get-LogicalDisks
$networkAdapters = Get-NetworkAdapters
$videoController = Get-VideoController


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



Write-Host "System Information" -ForegroundColor Green
Write-Host ""

# Computer System
Write-Host "1. Computer System"
Write-Host "------------------"
Write-Host "Manufacturer: $($computerSystem.Manufacturer)"
Write-Host "Model: $($computerSystem.Model)"
Write-Host "Serial Number: $($computerSystem.SerialNumber)"
Write-Host ""

# Operating System
Write-Host "2. Operating System"
Write-Host "--------------------"
Write-Host "Name: $($operatingSystem.Caption)"
Write-Host "Version: $($operatingSystem.Version)"
Write-Host ""

# Processor
Write-Host "3. Processor"
Write-Host "-------------"
Write-Host "Description: $($processor.Name)"
Write-Host "Speed: $($processor.MaxClockSpeed) MHz"
Write-Host "Number of Cores: $($processor.NumberOfCores)"
Write-Host "L1 Cache Size"
Write-Host ""

#Physical Memory
Write-Host "PhysicalMemory"
Write-Host "----------"
Write-Host "Manufacturer: $($physicalMemory.Manufacturer)"
Write-Host "Capacity: $($physicalMemory.Capacity)"
Write-Host ""

#Network adapter
Write-Host "NetworkAdapter"
Write-Host "----------"
$output | Format-Table -AutoSize -Wrap -Property "Adapter Description", "Adapter Index", "IP Address(es)", "Subnet Mask(s)", "DNS Domain Name", "DNS Server(s)" | Out-String | Write-Host

#Video vontroler
Write-Host "Video Controller"
Write-Host "----------"
Write-Host "AdapterCompatibility: $($videoController.AdapterCompatibility)"
Write-Host "Caption: $($videoController.Caption)"
Write-Host "CurrentHorizontalResolution: $($videoController.CurrentHorizontalResolution)"
Write-Host "CurrentVerticalResolution: $($videoController.CurrentVerticalResolution)"


