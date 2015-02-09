require 'spec_helper'

describe Telex::Emailer do
  let(:options) {{ email: 'foo@bar.com', subject: 'hi', body: 'ohhai' }}
  let(:emailer) { Telex::Emailer.new(options) }
  let(:mail)    { emailer.deliver! }

  it 'sets from' do
    expect(mail.from).to eq(%w( bot@heroku.com ))
  end

  it 'sets the subject' do
    expect(mail.subject).to eq('hi')
  end

  # see https://developers.google.com/gmail/markup/actions/actions-overview
  describe 'ld+json support for action shortcuts in GMail' do
    before do
      options.merge!(action: { label: 'View app', url: 'https://foo' })
    end

    it 'adds a script to the html body' do
      body = Nokogiri::HTML(mail.html_part.body.decoded)
      script = body.xpath("//script").first
      expect(script[:type]).to eq('application/ld+json')
      ld_json = MultiJson.load(script.text)
      expect(ld_json['@context']).to eq('http://schema.org')
      expect(ld_json['action']['@type']).to eq('ViewAction') # only supported Gmail type for now
      expect(ld_json['action']['name']).to eq('View app')
      expect(ld_json['action']['url']).to eq('https://foo')
    end
  end
end
