RSpec.shared_examples 'alpha version view', :alpha_version_view do
  it 'should show the alpha flag' do
    render
    expect(rendered).to have_selector('a.phase-flag.alpha', text: 'ALPHA')
  end
end

RSpec.shared_examples 'beta version view', :beta_version_view do
  it 'should show the beta flag' do
    render
    expect(rendered).to have_selector('a.phase-flag.alpha', text: 'BETA')
  end
end

RSpec.shared_examples 'stable version view', :stable_version_view do
  it 'should not show the alpha flag' do
    render
    expect(rendered).not_to have_selector('a.phase-flag.alpha', text: 'ALPHA')
  end

  it 'should not show the beta flag' do
    render
    expect(rendered).not_to have_selector('a.phase-flag.alpha', text: 'BETA')
  end
end
