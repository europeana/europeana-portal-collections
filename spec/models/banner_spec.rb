# frozen_string_literal: true

RSpec.describe Banner do
  it { is_expected.to have_one(:link).dependent(:destroy) }
  it { is_expected.to have_many(:pages).dependent(:nullify).inverse_of(:banner) }
  it { is_expected.to accept_nested_attributes_for(:link) }
  it { is_expected.to delegate_method(:url).to(:link).with_prefix(true) }
  it { is_expected.to delegate_method(:text).to(:link).with_prefix(true) }

  it 'should only permit one to be default' do
    expect(Banner.where(default: true).count).to eq(1)
    default_id_was = Banner.find_by_default(true).id

    new_default = Banner.new
    new_default.save
    new_default.publish!
    new_default.default = true
    new_default.save
    expect(new_default).to be_valid

    expect(Banner.where(default: true).count).to eq(1)
    default_id_is = Banner.find_by_default(true).id
    expect(default_id_is).not_to eq(default_id_was)
    expect(default_id_is).to eq(new_default.id)
  end
end
