RSpec.describe HeroImage do
  subject { FactoryGirl.create(:hero_image) }

  it { is_expected.to belong_to(:media_object) }
  it { is_expected.to delegate_method(:file).to(:media_object) }
  it { is_expected.to serialize(:attribution) }
  it { is_expected.to serialize(:brand) }
  it { is_expected.to delegate_method(:brand_opacity_enum).to(:class) }
  it { is_expected.to delegate_method(:brand_position_enum).to(:class) }
  it { is_expected.to delegate_method(:brand_colour_enum).to(:class) }
  it { is_expected.to accept_nested_attributes_for(:media_object) }
  it { is_expected.to validate_inclusion_of(:license).in_array(described_class.license_enum) }

  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(PaperTrail::Model::InstanceMethods)  }
  end

  describe '.license_enum' do
    subject { described_class.license_enum }
    it { is_expected.to eq(%w(CC0 CC_BY CC_BY_SA CC_BY_ND CC_BY_NC CC_BY_NC_SA CC_BY_NC_ND OOC PD_NC public RR_free RR_paid RR_restricted unknown orphan)) }
  end

  describe '.brand_opacity_enum' do
    subject { described_class.brand_opacity_enum }
    it { is_expected.to eq([25, 50, 75, 100]) }
  end

  describe '.brand_position_enum' do
    subject { described_class.brand_position_enum }
    it { is_expected.to eq(%w(topleft topright bottomleft bottomright)) }
  end

  describe '.brand_colour_enum' do
    subject { described_class.brand_colour_enum }
    it { is_expected.to eq(%w(site white black)) }
  end

  # @todo move into spec for DynamicAccessorMethods concern
  describe 'dynamic methods' do
    {
      attribution: %w(title creator institution url text),
      brand: %w(opacity position colour),
    }.each_pair do |attr, attr_meths|
      attr_meths.each do |meth|
        reader_meth = "#{attr}_#{meth}"
        describe "##{reader_meth}" do
          it { is_expected.to respond_to(reader_meth) }
          it "reads #{meth} from #{attr}" do
            expect(subject.send(reader_meth)).to eq(subject.send(:"#{attr}")[meth])
          end
        end

        writer_meth = "#{attr}_#{meth}=".to_sym
        describe "##{writer_meth}" do
          it { is_expected.to respond_to(writer_meth) }
          it "writes #{meth} to #{attr}" do
            expect { subject.send(writer_meth, 'new value') }.to change { subject.send(attr)[meth] }.to('new value')
          end
        end
      end
    end
  end

  context 'new record' do
    subject { FactoryGirl.build(:hero_image) }
    it 'has a media object built' do
      expect(subject.media_object).not_to be_nil
    end
  end
end
