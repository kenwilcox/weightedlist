use std::cmp::Ordering;
use std::collections::{BTreeSet, HashMap};
use std::env;
use std::ffi::OsStr;
use std::fs;
use std::io::Read;
use std::path::Path;

fn print_usage(program: &str) {
    eprintln!("Usage: {} <directory>", program);
}

fn is_txt_file(entry: &fs::DirEntry) -> bool {
    let path = entry.path();
    if !path.is_file() {
        return false;
    }
    match path.extension().and_then(OsStr::to_str) {
        Some(ext) => ext.eq_ignore_ascii_case("txt"),
        None => false,
    }
}

fn main() {
    let args = env::args().collect::<Vec<String>>();
    let program = Path::new(args.get(0).map(|s| s.as_str()).unwrap_or("program"))
        .file_name()
        .and_then(|s| s.to_str())
        .unwrap_or("program")
        .to_string();

    if args.len() != 2 {
        print_usage(&program);
        std::process::exit(1);
    }
    let dir = &args[1];
    let dir_path = Path::new(dir);
    let md = match fs::metadata(dir_path) {
        Ok(m) => m,
        Err(e) => {
            eprintln!("Error: {}", e);
            std::process::exit(1);
        }
    };
    if !md.is_dir() {
        eprintln!("Error: not a directory: {}", dir);
        std::process::exit(1);
    }

    // Maps: line -> count, and line -> distinct base names set
    let mut line_count: HashMap<String, usize> = HashMap::new();
    let mut line_to_names: HashMap<String, BTreeSet<String>> = HashMap::new();

    let entries = match fs::read_dir(dir_path) {
        Ok(iter) => iter,
        Err(e) => {
            eprintln!("Error reading directory: {}", e);
            std::process::exit(2);
        }
    };

    for entry_res in entries {
        let entry = match entry_res {
            Ok(e) => e,
            Err(e) => {
                eprintln!("Error reading directory entry: {}", e);
                std::process::exit(2);
            }
        };
        if !is_txt_file(&entry) {
            continue;
        }
        let path = entry.path();
        let file_name = path.file_name().and_then(|s| s.to_str()).unwrap_or("");
        let base = match Path::new(file_name).file_stem().and_then(|s| s.to_str()) {
            Some(b) => b.to_string(),
            None => continue,
        };

        let mut buf = Vec::new();
        match fs::File::open(&path) {
            Ok(mut f) => {
                if let Err(e) = f.read_to_end(&mut buf) {
                    eprintln!("Error reading file {}: {}", path.display(), e);
                    std::process::exit(2);
                }
            }
            Err(e) => {
                eprintln!("Error opening file {}: {}", path.display(), e);
                std::process::exit(2);
            }
        }
        let content = String::from_utf8_lossy(&buf);
        for line in content.split('\n') {
            // Strip trailing '\r' to handle Windows newlines, mimicking splitlines in other tools.
            let line = line.strip_suffix('\r').unwrap_or(line);
            // Preserve empty lines as valid entries.
            let count = line_count.entry(line.to_string()).or_insert(0);
            *count += 1;
            line_to_names
                .entry(line.to_string())
                .or_insert_with(BTreeSet::new)
                .insert(base.clone());
        }
    }

    // Collect items for sorting.
    let mut items: Vec<(String, usize)> = line_count.into_iter().collect();
    items.sort_by(|a, b| {
        match b.1.cmp(&a.1) { // count desc
            Ordering::Equal => a.0.cmp(&b.0), // line asc
            ord => ord,
        }
    });

    for (line, count) in items {
        let names = line_to_names.get(&line).map(|s| s.iter().cloned().collect::<Vec<_>>()).unwrap_or_else(Vec::new);
        let output = if names.is_empty() {
            format!("{} - {} ()", count, line)
        } else {
            format!("{} - {} ({})", count, line, names.join(", "))
        };
        println!("{}", output);
    }
}
