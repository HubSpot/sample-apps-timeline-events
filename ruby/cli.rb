require_relative 'config'
require 'optparse'
require 'ostruct'
require 'json'

class Cli
  def initialize(options)
    @options = options_with_default(options)
  end

  def run
    create_contact unless options[:contact_id]
    template_id = options[:template_id] || create_template&.id
    timeline_event = timeline_event(options[:email], template_id)
    create_timeline_event(timeline_event)
  end

  private

  attr_reader :options

  def options_with_default(options)
    options[:email] ||= 'timeline_events_app@hubspot.com'
    options[:firstname] ||= 'timeline'
    options[:lastname] ||= 'events'
    options[:template_object_type] ||= 'contacts'
    options[:template_name] ||= 'Test event template name'
    options[:template_header] ||= 'Test header'
    options[:template_detail] ||= 'Test detail'
    options
  end

  def create_contact
    api = ::Hubspot::Crm::Contacts::BasicApi.new
    api.create(contact, auth_names: 'hapikey')
  end

  def contact
    {
      email: options[:email],
      firstname: options[:firstname],
      lastname: options[:lastname]
    }.to_json
  end

  def create_template
    config = ::Hubspot::Crm::Timeline::Configuration.new do |config|
      config.api_key = { 'hapikey' => ENV['HUBSPOT_DEVELOPER_API_KEY'] }
    end

    api_client = ::Hubspot::Crm::Timeline::ApiClient.new(config)
    api = ::Hubspot::Crm::Timeline::TemplatesApi.new(api_client)
    api.create(
      ENV['HUBSPOT_APPLICATION_ID'],
      template_create_request,
      auth_names: 'developer_hapikey'
    )
  end

  def template_create_request
    {
      object_type: options[:template_object_type],
      name: options[:template_name],
      header_template: options[:template_header],
      detail_template: options[:template_detail]
    }.to_json
  end

  def create_timeline_event(timeline_event)
    api = ::Hubspot::Crm::Timeline::EventsApi.new
    api.create(timeline_event)
  end

  def timeline_event(email, template_id)
    ::Hubspot::Crm::Timeline::TimelineEvent.new(
      email: email,
      event_template_id: template_id
    )
  end
   
end

options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('-c', '--contact_id CONTACT_ID', 'Id of the existing contact') { |o| options.contact_id = o }
  opt.on('-e', '--email EMAIL', 'Email for the new contact') { |o| options.email = o }
  opt.on('-f', '--firstname FIRSTNAME', 'Frst name for the new contact') { |o| options.firstname = o }
  opt.on('-l', '--lastname LASTNAME', 'Last name for the new contact') { |o| options.lastname = o }
  opt.on('-t', '--template_id TEMPLATE_ID', 'Id of the existing template') { |o| options.template_id = o }
  opt.on('-o', '--object_type OBJECT_TYPE', 'Object type of the new template') { |o| options.template_object_type = o }
  opt.on('-n', '--name NAME', 'Name of the new template') { |o| options.template_name = o }
  opt.on('-h', '--header HEADER', 'Header of the new template') { |o| options.template_header = o }
  opt.on('-d', '--detail DETAIL', 'Detail of the new template') { |o| options.template_detail = o }
end.parse!

p Cli.new(options).run
