class Competition < ActiveRecord::Base
  belongs_to :format
  has_many   :divisions, dependent: :destroy

  validates :format, presence: true
  validates :name, presence: true, length: { in: 1..64 }
  validates :description, presence: true

  after_initialize :init

  def public?
    !private?
  end

  def public=(value)
    self.private = value
  end

  private

  def init
    self.private = true if private.nil?
  end
end
