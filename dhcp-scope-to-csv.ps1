# Define the DHCP server name
$serverName = Read-Host -Prompt “Enter servername”

# Define the output CSV file path
$outputFile = "C:\scripts\DHCP_Leases.csv"

# Define the headers for the CSV file
$headers = @("ScopeId", "IPAddress", "HostName", "ClientID", "AddressState")

# Initialize an empty array to store lease information
$leaseData = @()

# Get all DHCP scopes on the server
$scopes = Get-DhcpServerv4Scope -ComputerName $serverName

# Check if scopes are retrieved correctly
if ($scopes.Count -eq 0) {
    Write-Output "No scopes found on the DHCP server $serverName."
} else {
    Write-Output "Found $($scopes.Count) scopes on the DHCP server $serverName."
}

# Loop through each scope and get the leases
foreach ($scope in $scopes) {
    Write-Output "Processing scope with ID: $($scope.ScopeId)"

    # Attempt to retrieve leases for the current scope
    try {
        $leases = Get-DhcpServerv4Lease -ScopeId $scope.ScopeId -ComputerName $serverName

        if ($leases.Count -eq 0) {
            Write-Output "No leases found for scope ID: $($scope.ScopeId)"
        } else {
            Write-Output "Found $($leases.Count) leases for scope ID: $($scope.ScopeId)"
        }

        # Loop through each lease and extract the required information
        foreach ($lease in $leases) {
            $leaseData += [PSCustomObject]@{
                ScopeId      = $scope.ScopeId
                IPAddress    = $lease.IPAddress
                HostName     = $lease.HostName
                ClientID     = $lease.ClientId
                AddressState = $lease.AddressState
            }
        }
    }
    catch {
        Write-Output "Failed to retrieve leases for scope ID: $($scope.ScopeId). Error: $_"
    }
}

# Export the lease data to the CSV file if there is any data
if ($leaseData.Count -gt 0) {
    $leaseData | Export-Csv -Path $outputFile -NoTypeInformation -Delimiter ";"
    Write-Output "DHCP lease information has been exported to $outputFile"
} else {
    Write-Output "No lease data available to export."
}
