const std = @import("std");

const Entry = struct {
    count: usize = 0,
    names: std.StringHashMap(void), // set of distinct file base names
};

fn lessThanStrings(_: void, a: []const u8, b: []const u8) bool {
    return std.mem.lessThan(u8, a, b);
}

fn moreCount(_: void, a: Row, b: Row) bool {
    // sort by count desc; if equal, by key asc
    if (a.count == b.count) return std.mem.lessThan(u8, a.key, b.key);
    return a.count > b.count;
}

const Row = struct {
    key: []const u8,
    count: usize,
    names: [][]const u8,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args_it = try std.process.argsWithAllocator(allocator);
    defer args_it.deinit();

    _ = args_it.next(); // exe name
    const dir_path = args_it.next() orelse {
        std.debug.print("Usage: weightedlist <directory>\n", .{});
        return error.InvalidArgs;
    };

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const a = arena.allocator();

    var map = std.StringHashMap(Entry).init(a);

    // Open and iterate directory entries
    var dir = try std.fs.cwd().openDir(dir_path, .{ .iterate = true });
    defer dir.close();

    var it = dir.iterate();
    while (try it.next()) |e| {
        if (e.kind != .file) continue;
        if (!std.mem.endsWith(u8, e.name, ".txt")) continue;

        const base = e.name[0 .. e.name.len - 4];

        var file = try dir.openFile(e.name, .{});
        defer file.close();
        const contents = try file.readToEndAlloc(a, std.math.maxInt(usize));

        var line_it = std.mem.splitScalar(u8, contents, '\n');
        while (line_it.next()) |raw_line| {
            const line = std.mem.trim(u8, raw_line, " \r");
            if (line.len == 0) continue;

            var g = try map.getOrPut(line);
            if (!g.found_existing) {
                g.value_ptr.* = .{ .count = 0, .names = std.StringHashMap(void).init(a) };
            }
            g.value_ptr.count += 1;
            _ = try g.value_ptr.names.put(base, {});
        }
    }

    // Collect rows
    var rows = std.ArrayListUnmanaged(Row){};
    var iter = map.iterator();
    while (iter.next()) |kv| {
        const key = kv.key_ptr.*;
        const ent = kv.value_ptr.*;
        var name_list = std.ArrayListUnmanaged([]const u8){};
        var n_it = ent.names.keyIterator();
        while (n_it.next()) |name_ptr| {
            try name_list.append(a, name_ptr.*);
        }
        const names_slice = try name_list.toOwnedSlice(a);
        std.sort.pdqSort([]const u8, names_slice, {}, lessThanStrings);
        try rows.append(a, .{ .key = key, .count = ent.count, .names = names_slice });
    }

    const rows_slice = try rows.toOwnedSlice(a);
    std.sort.pdqSort(Row, rows_slice, {}, moreCount);

    for (rows_slice) |row| {
        std.debug.print("{d} - {s} (", .{ row.count, row.key });
        for (row.names, 0..) |n, i| {
            if (i > 0) std.debug.print(", ", .{});
            std.debug.print("{s}", .{n});
        }
        std.debug.print(")\n", .{});
    }
}