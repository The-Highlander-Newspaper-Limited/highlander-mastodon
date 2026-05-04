# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  FeedManager.prepend Custom::FeedLifecycleLogging::FeedManager
  User.prepend Custom::FeedLifecycleLogging::User
  RegenerationWorker.prepend Custom::FeedLifecycleLogging::RegenerationWorker
  Api::V1::Timelines::HomeController.prepend Custom::FeedLifecycleLogging::HomeTimelineController
end
