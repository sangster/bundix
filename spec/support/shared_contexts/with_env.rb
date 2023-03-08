# frozen_string_literal: true

RSpec.shared_context 'with env' do |env|
  around do |example|
    prev_env = env.to_h { |k, _| [k, ENV.fetch(k, nil)] }
    env.each { |k, v| ENV[k] = v }
    example.call
  ensure
    prev_env.each { |k, v| ENV[k] = v }
  end
end
