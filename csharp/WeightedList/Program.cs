var dir = Environment.GetCommandLineArgs();
var group = new Dictionary<string, List<string>>();
foreach (var file in Directory.EnumerateFiles(dir[1], "*.txt"))
{
    var name = Path.GetFileNameWithoutExtension(file);
    var lines = File.ReadAllLines(file);
    group.Add(name, lines.ToList());
}

group.SelectMany(kvp => kvp.Value
        .Select(line => new
        {
            Name = kvp.Key,
            Line = line
        }))
    .GroupBy(x => x.Line)
    .Select(g => new
    {
        g.Key,
        Count = g.Count(),
        Names = g.Select(p => p.Name)
            .Distinct()
            .OrderBy(n => n)
    })
    .OrderByDescending(x => x.Count)
    .ToList()
    .ForEach(x => Console.WriteLine($"{x.Count} - {x.Key} ({string.Join(", ", x.Names)})"));
    