module SeedData
  def self.extended(object)
    object.instance_exec do
      # Turn off paper_trail.
      PaperTrail.enabled = false

      # Users.
      @superadmin = User.create do |u|
        u.email        = 'superadmin@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @contributor = User.create do |u|
        u.email        = 'contributor@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @auditor = User.create do |u|
        u.email        = 'auditor@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @test_public = User.create do |u|
        u.email        = 'test_public@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @organizations = Organization.create([
        { name: 'Brown University' },
        { name: 'Johns Hopkins University' }
      ])

      # Organizations.
      @cochrane = Organization.create(name: 'Cochrane')
      @red_hair_pirates = Organization.create(name: 'Red Hair Pirates')
      @straw_hat_pirates = Organization.create(name: 'Straw Hat Pirates')
      @roger_pirates = Organization.create(name: 'Roger Pirates')

      # Add data to seed profiles.
      # Profiles are created in after_create callback in user model.
      @superadmin.profile.update(
        organization: @red_hair_pirates,
        username: 'superadmin',
        first_name: 'Red',
        middle_name: 'Haired',
        last_name: 'Shanks')
      @contributor.profile.update(
        organization: @straw_hat_pirates,
        username: 'contributor',
        first_name: 'Monkey',
        middle_name: 'D',
        last_name: 'Luffy')
      @auditor.profile.update(
        organization: @straw_hat_pirates,
        username: 'auditor',
        first_name: 'Nico',
        middle_name: '',
        last_name: 'Robin')
      @test_public.profile.update(
        organization: @roger_pirates,
        username: 'test_public',
        first_name: 'Gol',
        middle_name: 'D',
        last_name: 'Roger')

      # Degrees.
      @bachelor_arts = Degree.create(name: 'Bachelor of Arts - BA')
      @bachelor_science = Degree.create(name: 'Bachelor of Science - BS')
      @master_arts = Degree.create(name: 'Master of Arts - MA')
      @master_science = Degree.create(name: 'Master of Science - MS')
      @msph = Degree.create(name: 'Master of Science in Public Health - MSPH')
      @jd = Degree.create(name: 'Juris Doctor - JD')
      @md = Degree.create(name: 'Medical Doctor - MD')
      @phd = Degree.create(name: 'Doctor of Philosophy - PhD')

      # Suggestions.
      @cochrane.create_suggestion(user: @contributor)
      @red_hair_pirates.create_suggestion(user: @superadmin)
      @roger_pirates.create_suggestion(user: @superadmin)
      @msph.create_suggestion(user: @auditor)
      @jd.create_suggestion(user: @contributor)

      # Degrees-Profiles Associations.
      @bachelor_arts.profiles << @superadmin.profile
      @bachelor_arts.profiles << @contributor.profile
      @bachelor_science.profiles << @auditor.profile
      @master_arts.profiles << @superadmin.profile
      @master_science.profiles << @auditor.profile
      @msph.profiles << @superadmin.profile
      @msph.profiles << @contributor.profile
      @jd.profiles << @auditor.profile
      @msph.profiles << @auditor.profile

      # MessageTypes.
      @totd = MessageType.create(name: 'Tip Of The Day')
      MessageType.create([
        { name: 'General Announcement' },
        { name: 'Maintenance Announcement' }
      ])

      # Turn on paper_trail.
      PaperTrail.enabled = true

    end
  end
end

module SeedDataExtended
  def self.extended(object)
    object.instance_exec do
      # Turn off paper_trail.
      PaperTrail.enabled = false

      # Projects.
      1000.times do |n|
        Project.create(name:        Faker::Book.unique.title,
                       description: '(' + (n+1).to_s + ') - ' + Faker::ChuckNorris.fact,
                       attribution: Faker::Cat.registry,
                       methodology_description: Faker::HarryPotter.quote,
                       prospero:                Faker::Number.hexadecimal(12),
                       doi:                     Faker::Number.hexadecimal(6),
                       notes:                   Faker::HarryPotter.book,
                       funding_source:          Faker::Book.publisher)
        Faker::UniqueGenerator.clear
      end

      # Publishings.
      prng = Random.new
      Project.all.each do |p|
        requested_by = User.offset(rand(User.count)).first
        approved_by = User.offset(rand(User.count)).first
        case prng.rand(10)
        when 0  # Create Publishing object.
          p.request_publishing_by(requested_by)
        when 1  # Create Publishing object and approve it.
          Publishing.create(publishable: p, user: requested_by).approve_by(approved_by)
        else    # Don't do anything.
        end
      end

      # Messages.
      100.times do |m|
        @totd.messages.create(name: Faker::HarryPotter.unique.book, description: Faker::ChuckNorris.unique.fact)
        Faker::UniqueGenerator.clear
      end

      # Turn on paper_trail.
      PaperTrail.enabled = true
    end
  end
end
