namespace :user do
  desc 'Create a user account from EMAIL, PASSWORD and ROLE'
  task create: :environment do
    user = User.new(email: ENV['EMAIL'], password: ENV['PASSWORD'], role: ENV['ROLE'])
    if user.save
      puts ("Created".bold + " user with email \"#{user.email}\" and role \"#{user.role}\"").green
    else
      puts ("Failed".bold + " to create user:").red
      user.errors.full_messages.each do |err|
        puts "* #{err}".red
      end
      exit 1
    end
  end
end
