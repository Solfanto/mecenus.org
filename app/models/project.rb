class Project < ActiveRecord::Base
  PROTECTED_NAMES = %w(
    project projects user users profile 
    home create welcome help message messages 
    payment payments payment_settings settings search
    guidelines terms about contribute
    dashboard
    admin
    stripe paypal
  )

  belongs_to :user, counter_cache: :created_projects_count
  has_many :project_memberships
  has_many :members, through: :project_memberships, source: :user
  has_many :donations
  has_many :sponsors, through: :donations, source: :user
  has_many :posts
  has_many :payments
  has_many :donation_records

  validates :name, presence: true
  validates :name, exclusion: { in: PROTECTED_NAMES, message: "%{value} is reserved." }
  validates :name, uniqueness: true
  validates :repo_url, presence: true
  validates :license, presence: true
  validates :processing_day, numericality: { greater_than: 0, less_than: 29 }

  scope :published, -> { where(published: true) }
  scope :not_closed, -> { where(closed_at: nil) }
  scope :featured, -> { where("featured_from <= NOW() AND (featured_until >= NOW() OR featured_until IS NULL)") }

  validate :project_required_bank_information

  def project_required_bank_information
    if self.published
      valid = true
      self.errors.add("Bank information", "is incomplete.") && valid = false if self.user.stripe_account_id.nil?
      return valid
    end
    return true
  end

  def author
    self.user
  end

  def repo_type
    if self.repo_url =~ /github/
      "Github"
    else
      "Repository"
    end
  end

  def assign_to_creator
    membership = self.project_memberships.build
    membership.user = self.user
    membership.role = :admin
    self.project_memberships << membership
  end
  after_commit :assign_to_creator, on: :create

  def close
    self.closed_at = Time.now
    self.save
  end

  def close!
    self.closed_at = Time.now
    self.save!
  end

  def closed?
    self.closed_at != nil
  end

  def reopen
    self.closed_at = nil
    self.save
  end

  def reopen!
    self.closed_at = nil
    self.save!
  end

  def featured?
    now = Time.now
    self.featured_from&.send(:<=, now) && (self.featured_until.nil? || self.featured_until >= now)
  end

  def publish
    self.published = true
    self.save
  end

  def publish!
    self.published = true
    self.save!
  end

  def update_donation_amount_per_month
    self.donation_amount_per_month = self.donations.sum(:amount)
    self.save
  end
end
