# frozen_string_literal: true

require_relative '../../test_helper'

class TestShellNixContext < UnitTest
  def test_commandline_populates_context
    @cli = Bundix::CommandLine.new
    context = @cli.shell_nix_context

    Bundix::ShellNixContext.members.each do |field|
      refute_nil(context[field], "#{field} was nil")
    end
  end
end
