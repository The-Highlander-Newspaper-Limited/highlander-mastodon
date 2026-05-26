# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateAnnualReportWorker do
  let(:worker) { described_class.new }
  let(:account) { Fabricate :account }

  # highlander: annual report feature disabled on this fork; the worker is a no-op.
  describe '#perform' do
    it 'does not generate a report for the account' do
      expect { worker.perform(account.id, Date.current.year) }
        .to not_change(GeneratedAnnualReport, :count)
    end

    it 'does not raise for a non-existent account' do
      expect { worker.perform(123_123_123, Date.current.year) }.to_not raise_error
    end
  end
end
