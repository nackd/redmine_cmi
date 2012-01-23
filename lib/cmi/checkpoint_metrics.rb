module CMI
  class CheckpointMetrics < Metrics
    unloadable

    def initialize(checkpoint)
      @checkpoint = checkpoint
      @project = checkpoint.project
      @date = checkpoint.checkpoint_date
    end

    def time_scheduled
      (scheduled_finish_date - project.cmi_project_info.actual_start_date + 1).to_i
    end

    def time_remaining
      (scheduled_finish_date - date).to_i
    end

    def to_s
      checkpoint_date.to_s
    end

    private

    def method_missing(method, *args, &block)
      checkpoint.send method, *args, &block
    end
  end
end
