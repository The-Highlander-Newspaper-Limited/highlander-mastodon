# frozen_string_literal: true

class GenerateAnnualReportWorker
  include Sidekiq::Worker

  def perform(account_id, year) # rubocop:disable Lint/UnusedMethodArgument
    # highlander: annual report feature disabled; no-op so no GeneratedAnnualReport
    # rows or annual_report notifications are ever created on this fork.
    # AnnualReport.new(Account.find(account_id), year).generate
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordNotUnique
    true
  end
end
