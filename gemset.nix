{
  dependencies = ["bundix"];
  platforms = {
    ruby = {
      bundix = {
        dependencies = ["zeitwerk"];
        groups = ["default"];
        source = { path = ./.; type = "path"; };
        version = "3.0.0.pre.alpha";
      };
      zeitwerk = {
        groups = ["default"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "028ld9qmgdllxrl7d0qkl65s58wb1n3gv8yjs28g43a8b1hplxk1";
          type = "gem";
        };
        version = "2.6.7";
      };
    };
  };
}
