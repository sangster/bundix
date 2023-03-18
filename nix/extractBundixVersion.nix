{ ... }:

with builtins;
path:
let
  pattern = ".*VERSION[[:space:]]*=[[:space:]]['\"]([^'\"]+)['\"].*";
  captures = match pattern (readFile path);
  version-list = if isNull captures || length captures == 0
                 then [upstream-package.version]
                 else captures;
in elemAt version-list 0
