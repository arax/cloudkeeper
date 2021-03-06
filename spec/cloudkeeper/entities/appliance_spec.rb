require 'spec_helper'

describe Cloudkeeper::Entities::Appliance do
  subject(:appliance) { described_class.new 'identifier123', 'http://some/mpuri', 'vo', Time.new(2499, 12, 31, 22), 'identifier456' }

  let(:hash) { load_file 'appliance01.json', symbolize: true }

  describe '#new' do
    it 'returns instance of Appliance' do
      is_expected.to be_instance_of described_class
    end

    it 'prepares attributes attribute as a hash instance' do
      expect(appliance.attributes).to be_instance_of Hash
    end

    it 'prepares attributes attribute as an empty hash' do
      expect(appliance.attributes).to be_empty
    end

    context 'with nil identifier' do
      it 'raises ArgumentError exception' do
        expect { described_class.new nil, 'http://some/mpuri', 'vo', Time.new(2499, 12, 31, 22), 'identifier456' }.to \
          raise_error(Cloudkeeper::Errors::ArgumentError)
      end
    end

    context 'with nil mpuri' do
      it 'raises ArgumentError exception' do
        expect { described_class.new 'identifier123', nil, 'vo', Time.new(2499, 12, 31, 22), 'identifier456' }.to \
          raise_error(Cloudkeeper::Errors::ArgumentError)
      end
    end

    context 'with nil vo' do
      it 'raises ArgumentError exception' do
        expect { described_class.new 'identifier123', 'http://some/mpuri', nil, Time.new(2499, 12, 31, 22), 'identifier456' }.to \
          raise_error(Cloudkeeper::Errors::ArgumentError)
      end
    end

    context 'with nil expiration date' do
      it 'raises ArgumentError exception' do
        expect { described_class.new 'identifier123', 'http://some/mpuri', 'vo', nil, 'identifier456' }.to \
          raise_error(Cloudkeeper::Errors::ArgumentError)
      end
    end

    context 'with nil image list identifier' do
      it 'raises ArgumentError exception' do
        expect { described_class.new 'identifier123', 'http://some/mpuri', 'vo', Time.new(2499, 12, 31, 22), nil }.to \
          raise_error(Cloudkeeper::Errors::ArgumentError)
      end
    end
  end

  describe '#populate_attributes!' do
    it 'copies all values from hash to attributes attribute' do
      described_class.populate_attributes!(appliance, hash)
      expect(appliance.attributes).to eq(hash.map { |k, v| [k.to_s, v.to_s] }.to_h)
    end
  end

  describe '#construct_os_name!' do
    context 'with all name attributes available' do
      it 'sets appliance operating system to full name' do
        described_class.construct_os_name!(appliance, hash)
        expect(appliance.operating_system).to eq('Linux Other TinyCoreLinux')
      end
    end

    context 'with "sl:os" attribute missing' do
      before do
        hash[:'sl:os'] = nil
      end

      it 'sets appliance operating system to partial name' do
        described_class.construct_os_name!(appliance, hash)
        expect(appliance.operating_system).to eq('Other TinyCoreLinux')
      end
    end

    context 'with "sl:osname" attribute missing' do
      before do
        hash[:'sl:osname'] = nil
      end

      it 'sets appliance operating system to partial name' do
        described_class.construct_os_name!(appliance, hash)
        expect(appliance.operating_system).to eq('Linux TinyCoreLinux')
      end
    end

    context 'with no attributes available' do
      before do
        hash[:'sl:os'] = nil
        hash[:'sl:osname'] = nil
        hash[:'sl:osversion'] = nil
      end

      it 'sets appliance operating system to empty string' do
        described_class.construct_os_name!(appliance, hash)
        expect(appliance.operating_system).to be_empty
      end
    end
  end

  describe '#populate_appliance' do
    context 'with hash with correct values' do
      it 'populates and returns Appliance instance' do
        appliance = described_class.populate_appliance hash

        expect(appliance.identifier).to eq('2a5451eb-91f3-46a2-95a7-9cff7362d553')
        expect(appliance.description).to eq('This is a special Virtual Appliance entry used only for monitoring purposes.')
        expect(appliance.mpuri).to eq('https://appdb.somewhere.net/store/vm/image/2a5451eb-91f3-aaaa-95a7-9cff7362d553:6450:1469784811/')
        expect(appliance.title).to eq('Some Image')
        expect(appliance.group).to eq('General group')
        expect(appliance.ram).to eq(2048)
        expect(appliance.core).to eq(4)
        expect(appliance.version).to eq('0.0.5867')
        expect(appliance.architecture).to eq('x86_64')
        expect(appliance.operating_system).to eq('Linux Other TinyCoreLinux')
        expect(appliance.vo).to eq('some.dummy.vo')
        expect(appliance.expiration_date).to eq(Time.new(2016, 10, 25, 15, 57, 45))
        expect(appliance.image_list_identifier).to eq('76fdee70-8119-5d33-aaaa-3c57e1c60df1')
      end
    end

    context 'with hash with missing mandatory values' do
      before do
        hash[:'dc:identifier'] = nil
        hash[:'ad:mpuri'] = nil
      end

      it 'raises InvalidApplianceHashError exception' do
        expect { described_class.populate_appliance hash }.to raise_error(::Cloudkeeper::Errors::Parsing::InvalidApplianceHashError)
      end
    end

    context 'with hash with missing optional values' do
      before do
        hash[:'hv:core_minimum'] = nil
        hash[:'hv:version'] = nil
      end

      it 'populates and returns Image instance with missing values as nils' do
        appliance = described_class.populate_appliance hash

        expect(appliance.identifier).to eq('2a5451eb-91f3-46a2-95a7-9cff7362d553')
        expect(appliance.description).to eq('This is a special Virtual Appliance entry used only for monitoring purposes.')
        expect(appliance.mpuri).to eq('https://appdb.somewhere.net/store/vm/image/2a5451eb-91f3-aaaa-95a7-9cff7362d553:6450:1469784811/')
        expect(appliance.title).to eq('Some Image')
        expect(appliance.group).to eq('General group')
        expect(appliance.ram).to eq(2048)
        expect(appliance.core).to be_nil
        expect(appliance.version).to be_nil
        expect(appliance.architecture).to eq('x86_64')
        expect(appliance.operating_system).to eq('Linux Other TinyCoreLinux')
        expect(appliance.vo).to eq('some.dummy.vo')
        expect(appliance.expiration_date).to eq(Time.new(2016, 10, 25, 15, 57, 45))
        expect(appliance.image_list_identifier).to eq('76fdee70-8119-5d33-aaaa-3c57e1c60df1')
      end
    end

    context 'with empty hash' do
      let(:hash) { {} }

      it 'raises InvalidApplianceHashError exception' do
        expect { described_class.populate_appliance hash }.to raise_error(::Cloudkeeper::Errors::Parsing::InvalidApplianceHashError)
      end
    end

    context 'with nil hash' do
      let(:hash) { nil }

      it 'raises InvalidApplianceHashError exception' do
        expect { described_class.populate_appliance hash }.to raise_error(::Cloudkeeper::Errors::Parsing::InvalidApplianceHashError)
      end
    end

    context 'with hash with redundant values' do
      before do
        hash['redundant_key'] = 'redundant_value'
      end

      it 'populates and returns Appliance instance ignoring redundant values' do
        appliance = described_class.populate_appliance hash

        expect(appliance.identifier).to eq('2a5451eb-91f3-46a2-95a7-9cff7362d553')
        expect(appliance.description).to eq('This is a special Virtual Appliance entry used only for monitoring purposes.')
        expect(appliance.mpuri).to eq('https://appdb.somewhere.net/store/vm/image/2a5451eb-91f3-aaaa-95a7-9cff7362d553:6450:1469784811/')
        expect(appliance.title).to eq('Some Image')
        expect(appliance.group).to eq('General group')
        expect(appliance.ram).to eq(2048)
        expect(appliance.core).to eq(4)
        expect(appliance.version).to eq('0.0.5867')
        expect(appliance.architecture).to eq('x86_64')
        expect(appliance.operating_system).to eq('Linux Other TinyCoreLinux')
        expect(appliance.vo).to eq('some.dummy.vo')
        expect(appliance.expiration_date).to eq(Time.new(2016, 10, 25, 15, 57, 45))
        expect(appliance.image_list_identifier).to eq('76fdee70-8119-5d33-aaaa-3c57e1c60df1')
      end
    end
  end

  describe '#from_hash' do
    let(:hash) { load_file 'appliance02.json' }

    it 'creates Appliance instance from given hash' do
      appliance = described_class.from_hash hash

      expect(appliance.identifier).to eq('2a5451eb-91f3-46a2-95a7-9cff7362d553')
      expect(appliance.description).to eq('This is a special Virtual Appliance entry used only for monitoring purposes.')
      expect(appliance.mpuri).to eq('https://appdb.somewhere.net/store/vm/image/2a5451eb-91f3-aaaa-95a7-9cff7362d553:6450:1469784811/')
      expect(appliance.title).to eq('Some Image')
      expect(appliance.group).to eq('General group')
      expect(appliance.ram).to eq(2048)
      expect(appliance.core).to eq(4)
      expect(appliance.version).to eq('0.0.5867')
      expect(appliance.architecture).to eq('x86_64')
      expect(appliance.operating_system).to eq('Linux Other TinyCoreLinux')
      expect(appliance.vo).to eq('some.dummy.vo')
      expect(appliance.expiration_date).to eq(Time.new(2016, 10, 25, 15, 57, 45))
      expect(appliance.image_list_identifier).to eq('76fdee70-8119-5d33-aaaa-3c57e1c60df1')
      expect(appliance.image.size).to eq(42)
      expect(appliance.image.uri).to eq('http://some.uri.net/some/path')
      expect(appliance.image.checksum).to eq('81a106e4f352b2ff21c691280d9bfd3dfafdbe07154f414ae563d1786ff55a254e66e94e6644ae1f175'\
                                            '70a502cd46d3e7f2ece043fcd211818eed871f4aaef53')
    end
  end

  describe '.expired?' do
    context 'with expired appliance' do
      before do
        appliance.expiration_date = Time.new(1991, 10, 10)
      end

      it 'returns true' do
        expect(appliance).to be_expired
      end
    end

    context 'with non-expired appliance' do
      it 'returns false' do
        expect(appliance).not_to be_expired
      end
    end
  end
end
