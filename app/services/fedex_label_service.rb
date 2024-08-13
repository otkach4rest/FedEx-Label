# service = FedexLabelService.new
# service.generate_ca_shipment

class FedexLabelService
  attr_accessor :shipper, :recipient, :packages, :shipping_options, :label_specification, :service_type, :shipping_document, :filenames, :smart_post_detail

  def initialize
    @fedex = Fedex::Shipment.new(
      key: ENV['FEDEX_KEY'],
      password: ENV['FEDEX_PASSWORD'],
      account_number: ENV['FEDEX_ACCOUNT_NUMBER'],
      meter: ENV['FEDEX_METER'],
      mode: ENV['FEDEX_MODE']
    )
    
    set_defaults
  end

  def version_info
    {
      version: Fedex::VERSION,
      api_version: Fedex::API_VERSION,
      pickup_api_version: Fedex::PICKUP_API_VERSION,
      service_availability_api_version: Fedex::SERVICE_AVAILABILITY_API_VERSION
    }
    
  end

  def set_defaults
    @packages = []
    @service_type = "FEDEX_GROUND"
    @shipping_options = {
      packaging_type: "YOUR_PACKAGING",
      drop_off_type: "REGULAR_PICKUP"
    }
    # label_stock_type: 
    # PAPER_LETTER, STOCK_4X6, STOCK_4X6.75_LEADING_DOC_TAB, STOCK_4X6.75_TRAILING_DOC_TAB, STOCK_4X8, STOCK_4X9_LEADING_DOC_TAB, STOCK_4X9_TRAILING_DOC_TAB
    # OP_900_LG, OP_900_LG_B, OP_950, PAPER_4_PER_PAGE_PORTRAIT, PAPER_4X6, PAPER_8.5X11_TOP_HALF_LABEL, 

    @label_specification = {
      image_type: "PDF",
      label_stock_type: "STOCK_4X6"
      # label_stock_type: "PAPER_8.5X11_TOP_HALF_LABEL"
    }
  end

  def set_default_smart_posts
    @smart_post_detail = {
      indicia: 'PARCEL_SELECT',
      hub_id: 'YOUR_SMART_POST_HUB_ID'
    }
  end

  def set_label_specification(params)
    @label_specification = params
  end

  def set_shipper(params)
    @shipper = params
  end

  def set_recipient(params)
    @recipient = params
  end

  def set_packages(params)
    @packages = params
  end

  def set_shipping_options(params)
    @shipping_options = params
  end

  def set_shipping_document(params)
    @shipping_document = params
  end

  def set_filenames(params)
    @filenames = params
  end

  # FedEx Express Services
  #   INTERNATIONAL_FIRST: First international express service.
  #   INTERNATIONAL_PRIORITY: High-priority international express service.
  #   INTERNATIONAL_ECONOMY: Economical international express service.
  #   INTERNATIONAL_PRIORITY_FREIGHT: High-priority express freight service for international shipments.
  #   INTERNATIONAL_ECONOMY_FREIGHT: Economical express freight service for international shipments.
  # FedEx 

  # FEDEX_GROUND: This corresponds to FedEx Ground service, which is a reliable and cost-effective ground shipping option for domestic shipments within the United States. Delivery typically occurs within 1-7 business days, depending on the distance.
  # FEDEX_EXPRESS_SAVER: FedEx Express Saver is an option for express shipments with delivery in 3 business days by 4:30 p.m. to most areas.
  # FEDEX_2_DAY: This service offers two-day delivery for shipments within the United States.
  # FEDEX_STANDARD_OVERNIGHT: FedEx Standard Overnight is an overnight delivery service that delivers by 3 p.m. to most U.S. addresses.
  # FEDEX_PRIORITY_OVERNIGHT: FedEx Priority Overnight is a premium overnight delivery service that delivers by 10:30 a.m. to most U.S. addresses.
  # FEDEX_FIRST_OVERNIGHT: FedEx First Overnight is the fastest overnight service, with delivery as early as 8 a.m. to many U.S. addresses.
  # FEDEX_INTERNATIONAL_PRIORITY: This service is for international express shipments and provides fast delivery to international destinations.
  # FEDEX_INTERNATIONAL_ECONOMY: FedEx International Economy is a cost-effective international shipping option with slightly longer delivery times compared to International Priority.
  # FEDEX_INTERNATIONAL_FIRST: FedEx International First offers the fastest international shipping service, often with early morning delivery to international destinations.


  def set_service_type(service_type)
    @service_type = service_type
  end

  def generate_label(customs_details = nil)
    # Create a new temporary file
    temp_file = Tempfile.new(['fedex_label', '.pcx'])

    label_path = temp_file.path
    @fedex.label(
      filename: label_path,
      shipper: @shipper,
      recipient: @recipient,
      packages: @packages,
      service_type: @service_type,
      shipping_options: @shipping_options,
      label_specification: @label_specification,
      customs_clearance_detail: customs_details,
      shipping_document: @shipping_document,
      filenames: @filenames
    )
  end

  def generate_ca_shipment
    set_shipper(default_us_shipper)
    set_recipient(default_canadian_recipient)
    generate_label("/home/dev/fedex_solution/bunny.pcx", ca_customs_details)
  end

  private

  def default_us_shipper
    {
      name: "Sender",
      company: "Company",
      phone_number: "555-555-5555",
      address: "1202 Chalet Ln",
      city: "Harrison",
      state: "AR",
      postal_code: "72601",
      country_code: "US"
    }
  end

  def default_canadian_recipient
    {
      name: "Recipient",
      company: "Company",
      phone_number: "555-555-5555",
      address: "Address Line 1",
      city: "Richmond",
      state: "BC",
      postal_code: "V7C4V4",
      country_code: "CA",
      residential: "true"
    }
  end

  # def ca_customs_details
  #   {
  #     # broker: default_broker,
  #     # clearance_brokerage: "BROKER_INCLUSIVE",
  #     # importer_of_record: default_importer,
  #     # recipient_customs_id: { type: 'COMPANY', value: '1254587' },
  #     duties_payment: default_duties_payment,
  #     document_content: 'NON_DOCUMENTS',
  #     customs_value: {
  #       currency: 'UKL',
  #       amount: 155.79
  #     },
  #     commercial_invoice: {
  #       terms_of_sale: 'DDU'
  #     },
  #     commodities: default_commodities,
  #   }
  # end

  def ca_customs_details
    {
      # broker: default_broker,
      # clearance_brokerage: "BROKER_INCLUSIVE",
      # importer_of_record: default_importer,
      # recipient_customs_id: { type: 'COMPANY', value: '1254587' },
      duties_payment: default_duties_payment,
      document_content: 'NON_DOCUMENTS',
      customs_value: {
        currency: 'USD',
        amount: 155.79
      },
      commercial_invoice: {
        terms_of_sale: 'DDU'
      },
      commodities: default_commodities,
    }
  end

  def default_broker
    {
      account_number: "510087143",
      tins: {
        tin_type: "BUSINESS_NATIONAL",
        number: "431870271",
        usage: "Usage"
      },
      contact: {
        contact_id: "1",
        person_name: "Broker Name",
        title: "Broker",
        company_name: "Broker One",
        phone_number: "555-555-5555",
        phone_extension: "555-555-5555",
        pager_number: "555",
        fax_number: "555-555-5555",
        e_mail_address: "contact@me.com"
      },
      address: {
        street_lines: "Main Street",
        city: "Franklin Park",
        state_or_province_code: 'IL',
        postal_code: '60131',
        urbanization_code: '123',
        country_code: 'US',
        residential: 'false'
      }
    }
  end

  def default_importer
    {
      account_number: "22222",
      tins: {
        tin_type: "BUSINESS_NATIONAL",
        number: "22222",
        usage: "Usage"
      },
      contact: {
        contact_id: "1",
        person_name: "Importer Name",
        title: "Importer",
        company_name: "Importer One",
        phone_number: "555-555-5555",
        phone_extension: "555-555-5555",
        pager_number: "555",
        fax_number: "555-555-5555",
        e_mail_address: "contact@me.com"
      },
      address: {
        street_lines: "Main Street",
        city: "Chicago",
        state_or_province_code: 'IL',
        postal_code: '60611',
        urbanization_code: '2308',
        country_code: 'US',
        residential: 'false'
      }
    }
  end

  def default_duties_payment
    {
      payment_type: "SENDER",
      payor: {
        responsible_party: {
          account_number: ENV['FEDEX_ACCOUNT_NUMBER'],
          contact: {
            person_name: 'Mr. Test',
            phone_number: '12345678'
          }
        }
      }
    }
  end

  def default_commodities
    [{
      number_of_pieces: 1,
      description: 'Pink Toy',
      country_of_manufacture: 'GB',
      weight: {
        units: 'LB',
        value: 2
      },
      quantity: 1,
      quantity_units: 'EA',
      unit_price: {
        currency: 'USD',
        amount: 155.79
      },
      customs_value: {
        currency: 'USD',
        amount: 155.79
      }
    }]
  end

  def ex_document
    {
      :shipping_document_types => 'COMMERCIAL_INVOICE',
      :commercial_invoice_detail => {
        :format => {
          :image_type => 'PDF',
          :stock_type => 'PAPER_LETTER'
        }
      }
    }
  end

  def ex_filenames  
    {
      :label => File.join(Dir.tmpdir, "fedex_label_default.pdf"),
      :commercial_invoice => File.join(Dir.tmpdir, "fedex_invoice_default.pdf")
    }
  end

end
