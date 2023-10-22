# frozen_string_literal: true

# Include this class to your job and call with_limit to apply limitation
module JobConcurrency
  VERSION = '0.1.0'

  def redlock
    Redlock::Client.new(
      [ENV['REDIS_URL']]
    )
  end

  # Execute the block (yield) when it is possible or reschedule later
  #
  # @param queue_name [String] Name of the queue, the limitation apply for jobs in the same queue
  # @param max_concurrency [Integer] Number maximum of jobs that are executed in parallel on this queue
  # @param lock_expiration [Integer] After this duration the lock is release even if the job is not finish (ms)
  # @param minimum_interval [Integer] Minimum duration between the executions of 2 jobs in the same pool (ms)
  # @param job_params [Hash] Job params to use in case of retry
  # @param max_retry_delay [Integer] If pool is busy, your job will retry later in a random delay of max max_retry_delay seconds
  #
  # @example
  #
  # class MyJob
  #   include JobConcurrency
  #
  #   def perform
  #     with_limit(...) do
  #       # some stuff
  #     end
  #   end
  def with_limit(
    queue_name: default_queue_name,
    max_concurrency: default_max_concurrency,
    lock_expiration: default_lock_expiration,
    minimum_interval: default_minimum_interval,
    max_retry_delay: default_max_retry_relay,
    job_params: {}
  )
    job_done = false

    max_concurrency.times do |i|
      lock = redlock.lock("#{queue_name}-#{i}", lock_expiration)

      next unless lock

      start_job
      yield
      stop_job

      wait_interval(minimum_interval)

      redlock.unlock(lock)
      job_done = true

      break
    end

    self.class.set(wait: retry_random_delay(max_retry_delay)).perform_later(**job_params) unless job_done
  end

  def start_job
    @start_time = Time.now
  end

  def stop_job
    @end_time = Time.now
  end

  def job_duration
    @end_time - @start_time
  end

  def wait_interval(minimum_interval)
    sleep((minimum_interval - job_duration).to_f / 1000) if minimum_interval.positive?
  end

  def retry_random_delay(max)
    rand(max).seconds
  end

  def default_queue_name
    'default_job_concurrency_queue'
  end

  def default_max_concurrency
    1
  end

  def default_minimum_interval
    0
  end

  def default_lock_expiration
    1.minutes.in_milliseconds
  end

  def default_max_retry_relay
    360
  end
end
