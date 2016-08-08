require 'elasticsearch/model'

class Team < ActiveRecord::Base
  include Searchable
  include RosterMixin

  has_many :invites, dependent: :destroy
  has_many :transfers, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :rosters, class_name: 'League::Roster'

  validates :name, presence: true, uniqueness: true, length: { in: 1..64 }
  validates :description, presence: true, allow_blank: true

  mount_uploader :avatar, AvatarUploader

  alias_attribute :to_s, :name

  before_destroy :must_not_have_rosters, prepend: true

  def invite(user)
    invites.create(user: user)
  end

  def invite_for(user)
    invites.find_by(user: user)
  end

  def invited?(user)
    invites.exists?(user: user)
  end

  def entered?(comp)
    rosters.joins(:division)
           .where(league_divisions: { league_id: comp.id })
           .exists?
  end

  private

  def must_not_have_rosters
    if rosters.exists?
      errors.add(:id, 'can only destroy teams without any rosters')

      return false
    end
  end
end
