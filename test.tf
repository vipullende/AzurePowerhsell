resource "azurerm_application_gateway" "agw_nonpsub_t_sap_tnr_001" {
  name                = "agw_nonpsub_t_sap_tnr_001"
  depends_on          = [module.rg_nonpsub_t_sap_s4h_westus2]
  resource_group_name = "rg_nonpsub_t_sap_s4h_westus2"
  location            = "westus2"

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = "/subscriptions/5d26aadf-bc83-45db-908e-d9f69c2d27b9/resourceGroups/rg_NonProd_westus2/providers/Microsoft.Network/virtualNetworks/vNet_NonProd_Mnt_westus2/subnets/snet_nonpsub_appgateway_westus2_01"
  }

  frontend_ip_configuration {
    name                          = "appGwPrivateFrontendIp"
    private_ip_address            = "173.249.87.176"
    private_ip_address_allocation = "Static"
    subnet_id                     = "/subscriptions/5d26aadf-bc83-45db-908e-d9f69c2d27b9/resourceGroups/rg_NonProd_westus2/providers/Microsoft.Network/virtualNetworks/vNet_NonProd_Mnt_westus2/subnets/snet_nonpsub_appgateway_westus2_01"
  }

  frontend_port {
    name = "port_443"
    port = 443
  }
    frontend_port {
    name = "port_80"
    port = 80
  }

  backend_http_settings {
    name                                = "appgw-http-rule"
    cookie_based_affinity               = "Enabled"
    path                                = "/"
    port                                = 8443
    protocol                            = "Https"
    request_timeout                     = 20
    pick_host_name_from_backend_address = false
    #    probe_name                          = "health-probe"
    affinity_cookie_name = "ApplicationGatewayAffinity"
  }

  ssl_certificate {
    name                           = "tnrConeonenaCom_certificate"
    data                           = filebase64("tnr_certificate.pfx")
    password                       = "CONArun@2018!!!"
  }

  http_listener {
    name                           = "AGListnerHTTPS"
    frontend_ip_configuration_name = "appGwPrivateFrontendIp"
    frontend_port_name             = "port_443"
    protocol                       = "Https"
    require_sni                    = false
    ssl_certificate_name           = "tpi_certificate"
  }
    http_listener {
    frontend_port_name             = "port_80"
    name                           = "AGListnerHTTP"
    protocol                       = "Http"
    frontend_ip_configuration_name = "appGwPrivateFrontendIp"
  }
    redirect_configuration {
    include_path         = true
    include_query_string = true
    name                 = "http-to-https-redirect"
    redirect_type        = "Permanent"
    target_listener_name = "AGListnerHTTPS"
  }

  backend_address_pool {
    name  = "backend_pool_1"
    fqdns = ["altecc001.cokeonena.com", "alteca001.cokeonena.com", "alteca002.cokeonena.com", "alteca003.cokeonena.com"]
  }

  request_routing_rule {
    name                       = "AGRuleHTTPS"
    rule_type                  = "Basic"
    http_listener_name         = "AGListnerHTTPS"
    backend_address_pool_name  = "backend_pool_1"
    backend_http_settings_name = "appgw-http-rule"
    #priority                   = 10010
  }
    request_routing_rule {
    name                       = "AGRuleHTTP"
    rule_type                  = "Basic"
    http_listener_name         = "AGListnerHTTP"
    backend_address_pool_name  = "backend_pool_1"
    backend_http_settings_name = "appgw-http-rule"
  }


  ssl_policy {
    min_protocol_version = "TLSv1_2"
    #    policy_type          = "Custom"
    #    cipher_suites = ["TLS_RSA_WITH_AES_256_CBC_SHA256",
    #      "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384",
    #      "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
    #      "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256",
    #      "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256",
    #      "TLS_RSA_WITH_AES_128_GCM_SHA256",
    #    "TLS_RSA_WITH_AES_128_CBC_SHA256"]
  }

  #  firewall_policy_id                = azurerm_web_application_firewall_policy.waf_nonpsub_d_sap_s4h_westus2_01.id
  #  force_firewall_policy_association = true

tags = {
    ApplicationName                 = "S4 HANA"
    AvailabilitySchedule            = "24/7"
    Bottler                         = "Cona"
    BuildDate                       = "05/02/2023"
    BusinessImpact                  = "Medium"
    BusinessOwnerEmail              = "Uday Reddy <ureddy@conaservices.com>"
    CONAProcessArea                 = "NA"
    DataBackup                      = "NA"
    DataClassification              = "NA"
    DeploymentModel                 = "Terraform"
    DRClassification                = "NA"
    Landscape                       = "DryRun"
    MaintenanceSchedule             = "NA"
    OSType                          = "NA"
    OSVersion                       = "NA"
    PIP                             = "NO"
    Project                         = "S4 HANA"
    PublicAccessible                = "NO"
    RegulatoryCompliance            = "NA"
    ResourceGroup                   = "rg_nonpsub_t_sap_s4h_westus2"
    ShutDownSchedule                = "NA"
    SNOWTicket                      = "RITM0154715"
    SystemID                        = "TNR"
    TechnicalOwnerEmail             = "Ankan Chaudhuri <ankan.chaudhuri@capgemini.com>"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = []
  }
}

/*
resource "azurerm_web_application_firewall_policy" "waf_nonpsub_d_sap_s4h_westus2_01" {
  name                = "waf_nonpsub_d_sap_s4h_westus2_01"
  resource_group_name = "rg_nonpsub_d_sap_s4h_westus2"
  location            = "westus2"

  policy_settings {
    enabled                     = true
    mode                        = "Detection"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
    
    managed_rule_set {
      type    = "Microsoft_BotManagerRuleSet"
      version = "1.0"
    }
  }

  tags = {
    ApplicationName                 = "S4 HANA"
    AvailabilitySchedule            = "24/7"
    Bottler                         = "Cona"
    BuildDate                       = "04/24/2023"
    BusinessImpact                  = "Medium"
    BusinessOwnerEmail              = "Uday Reddy <ureddy@conaservices.com>"
    CONAProcessArea                 = "NA"
    DataBackup                      = "NA"
    DataClassification              = "NA"
    DeploymentModel                 = "Terraform"
    DRClassification                = "NA"
    Landscape                       = "Development"
    MaintenanceSchedule             = "NA"
    OSType                          = "NA"
    OSVersion                       = "NA"
    PIP                             = "NO"
    Project                         = "S4 HANA"
    PublicAccessible                = "NO"
    RegulatoryCompliance            = "NA"
    ResourceGroup                   = "rg_nonpsub_d_sap_s4h_westus2"
    ShutDownSchedule                = "NA"
    SNOWTicket                      = "RITM0154715"
    SystemID                        = "DNR"
    TechnicalOwnerEmail             = "Ankan Chaudhuri <ankan.chaudhuri@capgemini.com>"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = []
  }
}
*/
