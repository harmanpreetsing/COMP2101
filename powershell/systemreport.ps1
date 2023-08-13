[CmdletBinding()]
param (
    [switch]$System,
    [switch]$Disks,
    [switch]$Network,
    [switch]$Reports
)


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


function Get-FullReport {
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

# Physical Memory
Write-Host "4. Physical Memory"
Write-Host "------------------"
foreach ($memory in $physicalMemory) {
    Write-Host "Bank Label: $($memory.BankLabel)"
    Write-Host "Device Locator: $($memory.DeviceLocator)"
    Write-Host "Manufacturer: $($memory.Manufacturer)"
    Write-Host "Capacity: $($memory.Capacity)"
    Write-Host ""
}

# Logical Disks
Write-Host "5. Logical Disks"
Write-Host "----------------"
$logicalDisks | Format-Table -AutoSize -Wrap

# Network Adapters
Write-Host "6. Network Adapters"
Write-Host "-------------------"
$networkAdapters | Format-Table -AutoSize -Wrap

# Video Controller
Write-Host "7. Video Controller"
Write-Host "-------------------"
foreach ($video in $videoController) {
    Write-Host "Adapter Compatibility: $($video.AdapterCompatibility)"
    Write-Host "Caption: $($video.Caption)"
    Write-Host "Current Horizontal Resolution: $($video.CurrentHorizontalResolution)"
    Write-Host "Current Vertical Resolution: $($video.CurrentVerticalResolution)"
    Write-Host ""
}
}


$computerSystem = Get-ComputerSystem
$operatingSystem = Get-OperatingSystem
$processor = Get-Processor
$physicalMemory = Get-PhysicalMemory
$logicalDisks = Get-LogicalDisks
$networkAdapters = Get-NetworkAdapters
$videoController = Get-VideoController


# os 

$cpuUsage = Get-Counter '\Processor(_Total)\% Processor Time'
$cpuUsagePercentage = "{0:N2}%" -f ($cpuUsage.CounterSamples.CookedValue / $cpuUsage.CounterSamples.BaseValue)

# Get total and available RAM
$ram = Get-CimInstance Win32_OperatingSystem
$totalRam = "{0:N2} GB" -f ($ram.TotalVisibleMemorySize / 1GB)
$availableRam = "{0:N2} GB" -f ($ram.FreePhysicalMemory / 1GB)

# Get video card information
$videoCard = Get-CimInstance Win32_VideoController | Select-Object Name, AdapterRAM, DriverVersion




if ($System) {
    Write-Host "System Information" -ForegroundColor Green
    Write-Host ""

    # Computer System
    Write-Host "Computer System"
    Write-Host "------------------"
    Write-Host "Total RAM: $($totalRam)"
    Write-Host "Available RAM: $($availableRam)"
    Write-Host "cpuUsagePercentage $($cpuUsagePercentage)"
    Write-Host ""

    # Operating System
    Write-Host "Operating System"
    Write-Host "--------------------"
    Write-Host "Name: $($operatingSystem.Caption)"
    Write-Host "Version: $($operatingSystem.Version)"
    Write-Host "Architecture: $($operatingSystem.OSArchitecture)"
    Write-Host ""

   # Video Controller
   Write-Host "Video Controller"
   Write-Host "-------------------"
   $videoCard | Format-Table -AutoSize
   foreach ($video in $videoController) {
       Write-Host "Adapter Compatibility: $($video.AdapterCompatibility)"
       Write-Host "Caption: $($video.Caption)"
       Write-Host "Current Horizontal Resolution: $($video.CurrentHorizontalResolution)"
       Write-Host "Current Vertical Resolution: $($video.CurrentVerticalResolution)"
       Write-Host ""
    }
}
elseif ($Disks) {
    # Logical Disks
    Write-Host "Logical Disks"
    Write-Host "----------------"
    $logicalDisks | Format-Table -AutoSize -Wrap
}

elseif ($Network) {
    # Network Adapters
    Write-Host "Network Adapters"
    Write-Host "-------------------"
    $networkAdapters | Format-Table -AutoSize -Wrap
}

else {
   Get-FullReport
}




