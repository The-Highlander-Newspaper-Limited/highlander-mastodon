# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSettings do
  subject { described_class.new(json) }

  let(:json) { {} }

  describe '#[]=' do
    context 'when updating default_privacy' do
      it 'allows public and unlisted values' do
        expect { subject[:default_privacy] = 'public' }
          .to change { subject[:default_privacy] }.from(nil).to('public')

        expect { subject[:default_privacy] = 'unlisted' }
          .to change { subject[:default_privacy] }.from('public').to('unlisted')
      end

      it 'rejects private value' do
        expect { subject[:default_privacy] = 'private' }.to raise_error ArgumentError
      end
    end
  end
end
