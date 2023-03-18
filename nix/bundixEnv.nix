{ bundlerEnv
, callPackage
, ...
}@bundixEnvArgs:

bundlerEnv ((callPackage ./. {}).toBundlerEnvArgs bundixEnvArgs)
