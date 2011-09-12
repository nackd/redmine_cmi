class CmiCheckpoint < ActiveRecord::Base
  unloadable

  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  has_many :journals, :as => :journalized, :dependent => :destroy

  validates_presence_of :project, :author
  validates_format_of :checkpoint_date, :with => /^\d{4}-\d{2}-\d{2}$/, :message => :not_a_date, :allow_nil => false
  validates_format_of :scheduled_finish_date, :with => /^\d{4}-\d{2}-\d{2}$/, :message => :not_a_date, :allow_nil => false
  validates_numericality_of :scheduled_qa_meetings, :only_integer => true
  validate :role_effort

  serialize :scheduled_role_effort, Hash

  attr_protected :project_id, :author_id
  attr_reader :current_journal
  after_save :create_journal

  def scheduled_role_effort
    self[:scheduled_role_effort] ||= {}
  end

  def init_journal(user, notes = "")
    @current_journal ||= Journal.new(:journalized => self, :user => user, :notes => notes)
    @self_before_change = self.clone
    # Make sure updated_on is updated when adding a note.
    updated_at_will_change!
    @current_journal
  end

  private

  # Role effort validation
  def role_effort
    User.roles.each do |role|
      if scheduled_role_effort[role] =~ /\A[+-]?\d+\Z/
        scheduled_role_effort[role] = scheduled_role_effort[role].to_i
      else
        error = [I18n.translate(:"cmi.label_scheduled_role_effort", :role => role),
                 I18n.translate(:"activerecord.errors.messages.not_a_number")].join " "
        errors.add_to_base(error)
      end
    end
  end

  # Saves the changes in a Journal
  # Called after_save
  def create_journal
    if @current_journal
      # attributes changes
      (self.class.column_names - %w(id author_id created_at updated_at)).each {|c|
        @current_journal.details << JournalDetail.new(:property => 'attr',
                                                      :prop_key => c,
                                                      :old_value => @self_before_change.send(c),
                                                      :value => send(c)) unless send(c) == @self_before_change.send(c)
      }
      # custom fields changes
      @current_journal.save
      # reset current journal
      init_journal @current_journal.user, @current_journal.notes
    end
  end
end
