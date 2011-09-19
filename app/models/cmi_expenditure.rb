class CmiExpenditure < ActiveRecord::Base
  unloadable

  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  has_many :journals, :as => :journalized, :dependent => :destroy

  validates_presence_of :project, :author, :concept
  validates_numericality_of :initial_budget, :current_budget, :incurred

  attr_protected :project_id, :author_id
  attr_reader :current_journal
  after_save :create_journal

  def init_journal(user, notes = "")
    @current_journal ||= Journal.new(:journalized => self, :user => user, :notes => notes)
    @self_before_change = self.clone
    # Make sure updated_on is updated when adding a note.
    updated_at_will_change!
    @current_journal
  end

  private

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
