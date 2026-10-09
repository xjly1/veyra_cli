use std::fs;
use std::io;
use std::path::{Path, PathBuf};

pub fn run(save: bool, files: bool) -> io::Result<()> {
    let gitignore = GitIgnore::load(Path::new(".gitignore"))?;

    let mut output = String::new();

    output.push_str(".\n");

    build_tree(
        Path::new("."),
        "",
        files,
        &gitignore,
        &mut output,
    )?;

    if save {
        fs::write("structure_by_veyra.md", &output)?;

        println!("Project structure saved to structure_by_veyra.md.");
    } else {
        print!("{output}");
    }

    Ok(())
}

struct GitIgnore {
    rules: Vec<String>,
}

impl GitIgnore {
    fn load(path: &Path) -> io::Result<Self> {
        if !path.exists() {
            return Ok(Self { rules: Vec::new() });
        }

        let content = fs::read_to_string(path)?;

        let rules = content
            .lines()
            .map(str::trim)
            .filter(|line| !line.is_empty())
            .filter(|line| !line.starts_with('#'))
            .map(String::from)
            .collect();

        Ok(Self { rules })
    }

    fn is_ignored(&self, path: &Path) -> bool {
        let relative_path = match path.strip_prefix(".") {
            Ok(path) => path,
            Err(_) => path,
        };

        let path_string = relative_path
            .to_string_lossy()
            .replace('\\', "/");

        let file_name = path
            .file_name()
            .and_then(|name| name.to_str())
            .unwrap_or("");

        let mut ignored = false;

        for rule in &self.rules {
            let rule = rule.trim();

            if rule.is_empty() || rule.starts_with('#') {
                continue;
            }

            if let Some(rule) = rule.strip_prefix('!') {
                if matches_rule(rule, &path_string, file_name) {
                    ignored = false;
                }

                continue;
            }

            if matches_rule(rule, &path_string, file_name) {
                ignored = true;
            }
        }

        ignored
    }
}

fn matches_rule(rule: &str, path: &str, file_name: &str) -> bool {
    let rule = rule.trim_end_matches('/');

    if rule.is_empty() {
        return false;
    }

    if rule.starts_with('/') {
        let rule = rule.trim_start_matches('/');

        return wildcard_match(rule, path);
    }

    if rule.contains('/') {
        return wildcard_match(rule, path);
    }

    wildcard_match(rule, file_name)
}

fn wildcard_match(pattern: &str, text: &str) -> bool {
    wildcard_match_bytes(pattern.as_bytes(), text.as_bytes())
}

fn wildcard_match_bytes(pattern: &[u8], text: &[u8]) -> bool {
    if pattern.is_empty() {
        return text.is_empty();
    }

    match pattern[0] {
        b'*' => {
            wildcard_match_bytes(&pattern[1..], text)
                || (!text.is_empty()
                    && wildcard_match_bytes(pattern, &text[1..]))
        }

        b'?' => {
            !text.is_empty()
                && wildcard_match_bytes(&pattern[1..], &text[1..])
        }

        current => {
            !text.is_empty()
                && current == text[0]
                && wildcard_match_bytes(&pattern[1..], &text[1..])
        }
    }
}

fn build_tree(
    path: &Path,
    prefix: &str,
    show_files: bool,
    gitignore: &GitIgnore,
    output: &mut String,
) -> io::Result<()> {
    let mut entries: Vec<PathBuf> = Vec::new();

    for entry in fs::read_dir(path)? {
        let entry = entry?;
        let entry_path = entry.path();

        if gitignore.is_ignored(&entry_path) {
            continue;
        }

        if entry_path.is_dir() || show_files {
            entries.push(entry_path);
        }
    }

    entries.sort();

    for (index, path) in entries.iter().enumerate() {
        let is_last = index == entries.len() - 1;

        let branch = if is_last {
            "└── "
        } else {
            "├── "
        };

        let name = path
            .file_name()
            .and_then(|name| name.to_str())
            .unwrap_or("?");

        output.push_str(prefix);
        output.push_str(branch);
        output.push_str(name);

        if path.is_dir() {
            output.push('/');
        }

        output.push('\n');

        if path.is_dir() {
            let next_prefix = if is_last {
                format!("{prefix}    ")
            } else {
                format!("{prefix}│   ")
            };

            build_tree(
                path,
                &next_prefix,
                show_files,
                gitignore,
                output,
            )?;
        }
    }

    Ok(())
}