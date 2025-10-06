Reimplementation of [liblbos](https://forge.voremicrocomputers.com/Vore_Microcomputers/lifeblood_os/src/branch/develop/liblbos) in C3

Ignores some best practices in the name of a smaller binary.
If you want to keep safety/panic messages but the resulting binary is too large, remove the contracts in doc comments (`<* @require x != 0 *>` etc)
