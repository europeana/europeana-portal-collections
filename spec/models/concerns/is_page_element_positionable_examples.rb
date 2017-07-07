# frozen_string_literal: true

shared_examples_for 'page element positionable' do
  it { is_expected.to have_many(:page_elements).dependent(:destroy) }
  it { is_expected.to have_many(:page_element_groups).through(:page_elements).source(:group) }
  it { is_expected.to have_many(:pages).through(:page_element_groups) }
  it { is_expected.to callback(:touch_page_elements).after(:save) }
  it { is_expected.to callback(:touch_page_elements).after(:touch) }
  it { is_expected.to callback(:touch_page_elements).after(:destroy) }
end
