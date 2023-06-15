$payload = '{
    "schemaId": "azureMonitorCommonAlertSchema",
    "data": {
        "essentials": {
            "alertId": "/subscriptions/5d26aadf-bc83-45db-908e-d9f69c2d27b9/providers/Microsoft.AlertsManagement/alerts/1f30405d-16b6-4994-9d70-ab0b2d792c36",
            "alertRule": "cona-Certificate Expiry",
            "severity": "Sev3",
            "signalType": "Metric",
            "monitorCondition": "Fired",
            "monitoringService": "Platform",
            "alertTargetIDs": [
                "/subscriptions/5d26aadf-bc83-45db-908e-d9f69c2d27b9/resourcegroups/rg_nonpsub_m_pcl_westus2/providers/microsoft.network/applicationgateways/agw_nonpsub_m_pcl_002"
            ],
            "configurationItems": [
                "agw_nonpsub_m_pcl_002"
            ],
            "originAlertId": "5d26aadf-bc83-45db-908e-d9f69c2d27b9_rg_nonpsub_m_pcl_westus2_Microsoft.Insights_metricAlerts_agwfr-m-pcl-alert_-1096020369",
            "firedDateTime": "2023-05-31T22:15:37.428032Z",
            "resolvedDateTime": "2023-05-31T23:30:28.7494125Z",
            "description": "Cerificate is ging to exipre in 45 days",
            "essentialsVersion": "1.0",
            "alertContextVersion": "1.0"
        },
        "alertContext": {
            "properties": {
                "assignmentGroup": "77f382fe6ff80300e906841dba3ee458"
            },
            "conditionType": "DynamicThresholdCriteria",
            "condition": {
                "windowSize": "PT15M",
                "allOf": [
                    {
                        "alertSensitivity": null,
                        "failingPeriods": null,
                        "ignoreDataBefore": null,
                        "metricName": "FailedRequests",
                        "metricNamespace": "Microsoft.CertificateRegistration/certificateOrders",
                        "operator": null,
                        "threshold": null,
                        "timeAggregation": "Total",
                        "dimensions": [
                            {
                                "name": "ExpiryDateTime",
                                "value": "DateTime"
                            }
                        ],
                        "metricValue": null,
                        "webTestName": null
                    }
                ],
                "windowStartTime": "2023-05-31T23:12:24.931Z",
                "windowEndTime": "2023-05-31T23:27:24.931Z"
            }
        },
        "customProperties": {
            "AssignmentGroup": "77f382fe6ff80300e906841dba3ee458"
        }
    }
}'

$data = $payload | ConvertFrom-Json 
$data.data.essentials.configurationItems[0] =  "qbcplb.c1nacloud.com"
$data.data.essentials.firedDateTime = Get-Date -Format "o"
$data.data.alertContext.condition.allOf.dimensions[0].value = Get-Date -Format "o"
$datanew = $data | ConvertTo-Json  -Depth 20
$urllogic = "https://prod-15.westus2.logic.azure.com:443/workflows/d5c58bdcbda64ac4be946da2d6529e0e/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=qCjbyjGxbgXX-2vK7dYMMVAZEXXzt2Lej9AM9QSbu4Y"
Invoke-RestMethod -Method Post -Uri $urllogic -Body ($datanew) -ContentType "application/json"
