# frozen_string_literal: true

require 'redlock'
require 'job_concurrency'
require 'active_job'

RSpec.describe JobConcurrency do
  let(:fake_job_class) do
    Class.new(ActiveJob::Base) do
      include JobConcurrency

      def perform(options)
        with_limit(options) do
          do_stuff
        end
      end

      def do_stuff; end
    end
  end
  let(:options) do
    {
      lock_expiration: lock_expiration,
      queue_name: queue_name
    }
  end
  let(:fake_job) { fake_job_class.new(options) }
  let(:lock_manager) { instance_double(Redlock::Client) }
  let(:queue_name) { 'test_queue' }
  let(:max_concurrency) { 1 }
  let(:lock_expiration) { 1000 } # 1 second
  let(:minimum_interval) { 100 } # 100 milliseconds
  let(:max_retry_delay) { 360 }
  let(:job_params) { {} }
  let(:lock_response) { true }

  before do
    allow(Redlock::Client).to receive(:new).and_return(lock_manager)
    allow(lock_manager).to receive(:lock).with("#{queue_name}-0", lock_expiration).and_return(lock_response)
    allow(lock_manager).to receive(:unlock)
    spy(fake_job)
    allow(fake_job).to receive(:do_stuff).and_return(true)
    allow(fake_job_class).to receive(:set).and_call_original
  end

  describe '#with_limit' do
    context 'when 1 max concurrency' do
      context 'when a lock is available' do
        it 'executes the job' do
          fake_job.perform_now

          expect(fake_job).to have_received(:do_stuff).once
        end

        it 'releases the lock after execution' do
          lock_response = double('lock')

          expect(lock_manager).to receive(:lock).and_return(lock_response)
          expect(lock_manager).to receive(:unlock).with(lock_response)

          fake_job.perform_now
        end
      end

      context 'when no lock is available' do
        let(:lock_response) { false }

        it 'does not executes the job' do
          fake_job.perform_now

          expect(fake_job).not_to have_received(:do_stuff)
        end

        it 'calls perform_in' do
          fake_job.perform_now

          expect(fake_job_class).to have_received(:set).with(wait: anything)
        end
      end
    end
  end

  # Add more test cases as needed to cover other scenarios.
end
