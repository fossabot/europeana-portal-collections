describe Europeana::Portal::Application, 'configuration' do
  let(:config) { described_class.config }

  it 'has channels config' do
    expect(config.channels).not_to be_blank
  end

  it 'sets paperclip defaults' do
    expect(config.paperclip_defaults[:styles]).to have_key(:small)
  end
end