resource "google_clouddomains_registration" "my_domain" {
  project     = "${{ values.projectId }}"
  domain_name = "${{ values.domainName }}"
  location    = "global"

  contact_settings {
    privacy = "PRIVATE_CONTACT_DATA"
    # Hinweis: In Produktion müssten hier noch detaillierte Kontaktinfos stehen
    registrant_contact {
      email        = "admin@${{ values.domainName }}"
      phone_number = "+49.123456789"
      postal_code  = "12345"
      region_code  = "DE"
      address_lines = ["Street 1"]
    }
    admin_contact {
      email        = "admin@${{ values.domainName }}"
      phone_number = "+49.123456789"
      postal_code  = "12345"
      region_code  = "DE"
      address_lines = ["Street 1"]
    }
    technical_contact {
      email        = "admin@${{ values.domainName }}"
      phone_number = "+49.123456789"
      postal_code  = "12345"
      region_code  = "DE"
      address_lines = ["Street 1"]
    }
  }

  yearly_price {
    currency_code = "USD"
    units         = 12
  }

  dns_settings {
    custom_dns {
      # Hier könnte man die Cloud DNS Zonen eintragen
    }
  }
}
