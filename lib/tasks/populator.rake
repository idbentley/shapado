require 'faker'

namespace :populator do
  desc "Creates 10 random questions"
  task :questions => :environment do
    users = User.find(:all, :limit => 20)
    raise "There are no users!" if users.empty?
    default_group = Group.find_by_name(AppConfig.application_name)

    10.times do
      q = Question.new(:title =>  Faker::Lorem.words(rand(6)+6).join(" "),
                       :body => Faker::Lorem.paragraphs(rand(10)+6),
                       :language => (rand(100) % 2 == 0) ? 'en' : 'es',
                       :tags => Faker::Lorem.words(rand(6)+1),
                       :category => Shapado::CATEGORIES.rand,
                       :banned => false)
      q.group = default_group
      q.user = users.rand
      q.save!

      rand(20).times do |i|
        a = Answer.new( :user => users.rand,
                        :body => Faker::Lorem.paragraphs(rand(10)+1),
                        :language => (rand(100) % 2 == 0) ? 'en' : 'es')
        a.group_id = q.group_id
        q.answers << a
        q.answer_added!
        rand(10).times do |i|
          f = Flag.new(:flaggeable_id => a.id,
                       :flaggeable_type => a.class.name,
                       :user => users.rand,
                       :type => Flag::TYPES[rand(Flag::TYPES.size)],
                       :banned => false)
          f.save
          a.flagged!
        end
      end

      rand(10).times do |i|
        f = Flag.new(:flaggeable_id => q.id,
                     :flaggeable_type => q.class.name,
                     :user => users.rand,
                     :type => Flag::TYPES[rand(Flag::TYPES.size)])
        f.save
        q.flagged!
      end

    end
  end

  desc "Creates 10 random users"
  task :users => :environment do
    10.times do
      user = User.create(:login => Faker::Internet.user_name.gsub(/\W/, "-"),
                         :email => Faker::Internet.email,
                         :name => Faker::Name.name,
                         :password => "test123", :password_confirmation => "test123")
    end
  end
end

