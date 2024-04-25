// basic usage: dice d4 d12 d10
// expected output:
//               3 10 1

const std = @import("std");

// internal rapresentation of a dice (just a named value to match on)
const Dice = enum {
    D4,
    D6,
    D8,
    D10,
    D12,
    D20,
    pub fn roll(self: Dice, prng: *std.rand.Xoshiro256) u32 {
        switch (self) {
            Dice.D4 => return prng.random().intRangeAtMost(u32, 1, 4),
            Dice.D6 => return prng.random().intRangeAtMost(u32, 1, 6),
            Dice.D8 => return prng.random().intRangeAtMost(u32, 1, 8),
            Dice.D10 => return prng.random().intRangeAtMost(u32, 1, 10),
            Dice.D12 => return prng.random().intRangeAtMost(u32, 1, 12),
            Dice.D20 => return prng.random().intRangeAtMost(u32, 1, 20),
        }
    }
};

pub fn stringToDice(string: []const u8) Dice {
    if (std.mem.eql(u8, string, "d4")) {
        return Dice.D4;
    } else if (std.mem.eql(u8, string, "d6")) {
        return Dice.D6;
    } else if (std.mem.eql(u8, string, "d8")) {
        return Dice.D8;
    } else if (std.mem.eql(u8, string, "d10")) {
        return Dice.D10;
    } else if (std.mem.eql(u8, string, "d12")) {
        return Dice.D12;
    } else if (std.mem.eql(u8, string, "d20")) {
        return Dice.D20;
    } else {
        return Dice.D20;
    }
}
pub fn main() !void {
    // defining standard output, with a buffered writer
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.child_allocator;
    // args iterator
    var args = try std.process.argsWithAllocator(allocator);
    // defining the pseudo random number generator
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    if (args.skip()) {
        while (args.next()) |arg| {
            try stdout.print("{} ", .{stringToDice(arg).roll(&prng)});
        }
    }
    try stdout.print("\n", .{});
    try bw.flush(); // don't forget to flush!
}
