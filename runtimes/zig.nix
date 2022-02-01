{pkgs, piston, ...}:
let
    pkg = pkgs.zig;
in piston.mkRuntime {
    language = "zig";
    version = pkg.version;
    aliases = [];

    # Add .zig extension for compile script and optimize compiler for small programs
    compile = ''
        rename 's/$/\.zig/' "$@"
        ${pkg}/bin/zig build-exe -O ReleaseSafe --color off --cache-dir . --global-cache-dir . --name out *.zig
    '';

    # Remove first arg filename and run binary with remaining args
    run = ''
        shift
        ./out "$@"
    '';

    # These should output "OK" to STDOUT if everything looks good
    # Run the following command to test the package:
    # $ ./piston test zig
    tests = [
        # Standard output test
        (piston.mkTest {
            files = {
                "test.zig" = ''
                    const std = @import("std");

                    pub fn main() !void {
                        const stdout = std.io.getStdOut().writer();
                        try stdout.print("OK\n", .{});
                    }
                '';
            };
            args = [];
            stdin = "";
            packages = [];
            main = "test.zig";
        })
    ];
}
