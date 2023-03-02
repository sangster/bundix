# frozen_string_literal: true

module Bundix
  ShellNixContext = Struct.new(:project, :ruby, :gemfile, :lockfile, :gemset,
                               keyword_init: true) do
    def bind
      binding
    end

    def path_for(file)
      Nixer.serialize(Pathname(file).relative_path_from(Pathname('./')))
    end

    def gemfile_path
      path_for(gemfile)
    end

    def lockfile_path
      path_for(lockfile)
    end

    def gemset_path
      path_for(gemset)
    end
  end
end
