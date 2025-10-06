module lbos::panic;

alias PanicFn = fn void(String, String, String, uint);
PanicFn panic = fn (message, file, function, line)
{
	// lbos::printlns("Panic: \"", message, "\" in \"", file, "\":\"", function, "\"");
	$if env::PANIC_MSG:
		printlns("\nPANIC!: ", message);
	$endif
	$$trap();
};

macro abort(String message) @builtin @noreturn
{
	panic(message, "", "", 0);
}

macro unreachable(String message) @builtin @noreturn
{
	$if env::COMPILER_SAFE_MODE:
		panic(message, "", "", 0);
	$endif
	$$trap();
}
