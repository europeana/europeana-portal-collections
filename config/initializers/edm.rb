rights = YAML.load_file(File.join(Rails.root, 'config', 'edm', 'rights.yml'))
EDM::Rights.load(rights)
