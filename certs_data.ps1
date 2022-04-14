$certs = Get-AzResource | where {$_.ResourceType -contains "Microsoft.CertificateRegistration/certificateOrders"}
$certs.Count
Get-AzWebApp -ResourceGroupName $certs[0].ResourceGroupName
Get-AzCertificate -ResourceGroupName rg_nonpsub_m_ame_westus2