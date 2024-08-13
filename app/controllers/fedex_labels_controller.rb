class FedexLabelsController < ApplicationController
  def index
    @labels = FedexLabel.all
    @version_info = FedexLabelService.new.version_info
  end

  def show
    @label = FedexLabel.find(params[:id])
  end

  def new
    @shipper = {}

    @recipient = {}

    @packages = []
    @packages << {
      weight: { units: 'LB', value: 2 },
      dimensions: { length: 10, width: 5, height: 4, units: 'IN' }
    }
    # packages << {
    #   :weight => {:units => "LB", :value => 6},
    #   :dimensions => {:length => 5, :width => 5, :height => 4, :units => "IN" }
    # }

    @shipping_options = {
      packaging_type: 'YOUR_PACKAGING',
      drop_off_type: 'REGULAR_PICKUP'
    }

    @payment_options = {
      type: 'THIRD_PARTY',
      account_number: '123456789',
      name: 'Third Party Payor',
      company: 'Company',
      phone_number: '555-555-5555',
      country_code: 'US'
    }

    @example_spec = {
      image_type: 'EPL2', #PDF
      label_stock_type: 'STOCK_4X6'
    }
  end

  def new_fedex_label_with_us_recipient
    @shipper = { name: 'Sender',
                 company: 'Company',
                 phone_number: '555-555-5555',
                 address: '1202 Chalet Ln',
                 city: 'Harrison',
                 state: 'AR',
                 postal_code: '72601',
                 country_code: 'US' }

    @recipient = { name: 'Recipient',
                   company: 'Company',
                   phone_number: '555-555-5555',
                   address: 'Main Street',
                   city: 'Franklin Park',
                   state: 'IL',
                   postal_code: '60131',
                   country_code: 'US',
                   residential: 'false' }

    @packages = []
    @packages << {
      weight: { units: 'LB', value: 2 },
      dimensions: { length: 10, width: 5, height: 4, units: 'IN' }
    }
    # packages << {
    #   :weight => {:units => "LB", :value => 6},
    #   :dimensions => {:length => 5, :width => 5, :height => 4, :units => "IN" }
    # }

    @shipping_options = {
      packaging_type: 'YOUR_PACKAGING',
      drop_off_type: 'REGULAR_PICKUP'
    }

    @payment_options = {
      type: 'THIRD_PARTY',
      account_number: '123456789',
      name: 'Third Party Payor',
      company: 'Company',
      phone_number: '555-555-5555',
      country_code: 'US'
    }

    @example_spec = {
      image_type: 'EPL2',
      label_stock_type: 'STOCK_4X6'
    }
    render 'new'
  end

  def new_fedex_label_with_ca_recipient
    @recipient = { name: 'Recipient', company: 'Company', phone_number: '555-555-5555',
                   address: 'Address Line 1', city: 'Richmond', state: 'BC', postal_code: 'V7C4V4', country_code: 'CA', residential: 'true' }
    @shipper = { name: 'Sender',
                 company: 'Company',
                 phone_number: '555-555-5555',
                 address: '1202 Chalet Ln',
                 city: 'Harrison',
                 state: 'AR',
                 postal_code: '72601',
                 country_code: 'US' }

    @packages = [
      {
        weight: { units: 'LB', value: 6 },
        dimensions: { length: 5, width: 5, height: 4, units: 'IN' }
      }
    ]
    @example_spec = {
      image_type: 'EPL2',
      label_stock_type: 'STOCK_4X6'
    }
    @shipping_options = {
      packaging_type: 'YOUR_PACKAGING',
      drop_off_type: 'REGULAR_PICKUP'
    }
    @customs = {
      duties_payment: {
        payment_type: 'SENDER',
        payor: {
          responsible_party: {
            account_number: ENV['FEDEX_ACCOUNT_NUMBER'],
            contact: {
              person_name: 'Mr. Test',
              phone_number: '12345678'
            }
          }
        }
      },
      document_content: 'NON_DOCUMENTS',
      customs_value: {
        currency: 'USD', # UK Pounds Sterling
        amount: 155.79
      },
      commercial_invoice: {
        terms_of_sale: 'DDU'
      },
      commodities: [
        {
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
        }
      ]
    }
    render 'new_ca'
  end

  def new_fedex_label_with_jp_recipient
    @shipper = { name: 'Sender',
                 company: 'Company',
                 phone_number: '555-555-5555',
                 address: '1202 Chalet Ln',
                 city: 'Harrison',
                 state: 'AR',
                 postal_code: '72601',
                 country_code: 'US' }

    @recipient = { name: 'Yasuda Saki',
                   company: 'Japan Grocery Inc.',
                   phone_number: '555-555-5555',
                   address: 'Times, South Tanaka Nakacho Asahicho Line',
                   city: 'Tokyo',
                   postal_code: '179-0074',
                   country_code: 'JP',
                   residential: 'false' }

    @packages = [
      {
        weight: { units: 'LB', value: 6 },
        dimensions: { length: 5, width: 5, height: 4, units: 'IN' }
      }
    ]
    
    render 'new_jp'
  end

  def create
    fedex = Fedex::Shipment.new(key: ENV['FEDEX_KEY'],
                                password: ENV['FEDEX_PASSWORD'],
                                account_number: ENV['FEDEX_ACCOUNT_NUMBER'],
                                meter: ENV['FEDEX_METER'],
                                mode: ENV['FEDEX_MODE'])

    shipper = params[:shipper]
    recipient = params[:recipient]

    packages = []
    packages << {
      weight: { units: 'LB', value: 2 },
      dimensions: { length: 10, width: 5, height: 4, units: 'IN' }
    }

    # packages << {
    #   :weight => {:units => "LB", :value => 6},
    #   :dimensions => {:length => 5, :width => 5, :height => 4, :units => "IN" }
    # }
    shipping_options = {
      packaging_type: 'YOUR_PACKAGING',
      drop_off_type: 'REGULAR_PICKUP'
    }

    payment_options = {
      type: 'THIRD_PARTY',
      account_number: '123456789',
      name: 'Third Party Payor',
      company: 'Company',
      phone_number: '555-555-5555',
      country_code: 'US'
    }

    example_spec = {
      image_type: 'EPL2',
      label_stock_type: 'STOCK_4X6'
    }

    label = fedex.label(filename: '/home/dev/fedex_solution/bunny.pcx',
                        shipper:,
                        recipient:,
                        packages:,
                        service_type: 'FEDEX_GROUND',
                        shipping_options:,
                        label_specification: example_spec)

    FedexLabel.create(image: label.image, options: label.options, response_details: label.response_details)
    redirect_to fedex_labels_path
  end

  def create_international
    service = FedexLabelService.new
    service.set_shipper(params[:shipper].to_unsafe_h)
    service.set_recipient(params[:recipient].to_unsafe_h)
    
    service.set_service_type("FEDEX_GROUND") # works fine in Canada
    
    # service.set_service_type("SMART_POST") 
    
    # service.service_type = "INTERNATIONAL_PRIORITY" # work in Japan
    # service.set_service_type("INTERNATIONAL_ECONOMY") # work in Japan
    # service.service_type = "INTERNATIONAL_PRIORITY"  # INTERNATIONAL_FIRST, INTERNATIONAL_PRIORITY, INTERNATIONAL_ECONOMY, INTERNATIONAL_PRIORITY_FREIGHT, INTERNATIONAL_ECONOMY_FREIGHT

    packages = [
      {
        weight: { units: 'LB', value: 6 },
        dimensions: { length: 5, width: 5, height: 4, units: 'IN' }
      }
    ]
    service.set_packages(packages)
    
    ca_customs_details = service.send(:ca_customs_details)
    ex_document =  service.send(:ex_document)
    ex_filenames =  service.send(:ex_filenames)

    service.set_shipping_document(ex_document)
    service.set_filenames(ex_filenames)

    label = service.generate_label(ca_customs_details)
    
    FedexLabel.create(image: label.image, options: label.options, response_details: label.response_details)
    redirect_to fedex_labels_path
  end

  def download
    @label = FedexLabel.find(params[:id])
    send_data @label.image, filename: 'label.pdf', type: 'application/pdf', disposition: 'inline'
  end


  def generate_labels(service_type, label_stock_type)
    service = FedexLabelService.new

    recipient = { name: 'Recipient', company: 'Company', phone_number: '555-555-5555',
                   address: 'Address Line 1', city: 'Richmond', state: 'BC', postal_code: 'V7C4V4', country_code: 'CA', residential: 'true' }
    shipper = { name: 'Sender',
                 company: 'Company',
                 phone_number: '555-555-5555',
                 address: '1202 Chalet Ln',
                 city: 'Harrison',
                 state: 'AR',
                 postal_code: '72601',
                 country_code: 'US' }


    service.set_shipper(shipper)
    service.set_recipient(recipient)
    
    service.set_service_type("FEDEX_GROUND") # works fine in Canada
    
    # service.set_service_type("SMART_POST") 
    
    # service.service_type = "INTERNATIONAL_PRIORITY" # work in Japan
    # service.set_service_type("INTERNATIONAL_ECONOMY") # work in Japan
    # service.service_type = "INTERNATIONAL_PRIORITY"  # INTERNATIONAL_FIRST, INTERNATIONAL_PRIORITY, INTERNATIONAL_ECONOMY, INTERNATIONAL_PRIORITY_FREIGHT, INTERNATIONAL_ECONOMY_FREIGHT

    packages = [
      {
        weight: { units: 'LB', value: 6 },
        dimensions: { length: 5, width: 5, height: 4, units: 'IN' }
      }
    ]
    service.set_packages(packages)
    
    ca_customs_details = service.send(:ca_customs_details)
    ex_document =  service.send(:ex_document)
    ex_filenames =  service.send(:ex_filenames)

    service.set_shipping_document(ex_document)
    service.set_filenames(ex_filenames)

    service.set_label_specification({
      image_type: "PDF",
      label_stock_type: label_stock_type
    })
    label = service.generate_label(ca_customs_details)
    FedexLabel.create(image: label.image, options: label.options, response_details: label.response_details, service_type: service_type, label_stock_type: label_stock_type)
  end

  def generate_all_labels
    service_types = [ 'FEDEX_GROUND' ]

    # label_stock_types = %w(PAPER_4X6 PAPER_4X6.75 PAPER_4X8 PAPER_4X9 PAPER_7X4.75 PAPER_8.5X11_BOTTOM_HALF_LABEL PAPER_8.5X11_TOP_HALF_LABEL STOCK_4X6 STOCK_4X6.75 STOCK_4X6.75_LEADING_DOC_TAB STOCK_4X6.75_TRAILING_DOC_TAB STOCK_4X8 STOCK_4X9 STOCK_4X9_LEADING_DOC_TAB STOCK_4X9_TRAILING_DOC_TAB)

    # PAPER_4X6.75 STOCK_4X6.75 STOCK_4X6.75_LEADING_DOC_TAB STOCK_4X6.75_TRAILING_DOC_TAB STOCK_4X9 STOCK_4X9_LEADING_DOC_TAB=> error
    
    label_stock_types.each do |label_stock_type|
      puts "Processing: #{label_stock_type}"
      generate_labels('FEDEX_GROUND', label_stock_type)
    end
  end

end
