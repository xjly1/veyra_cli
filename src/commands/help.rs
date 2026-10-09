
use rust_embed::RustEmbed;
use std::io;

#[derive(RustEmbed)]
#[folder = "src/help/"]
struct HelpAssets;

struct HelpCommand {
    command: String,
    description: String,
}

pub fn run() -> io::Result<()> {
    let mut commands = Vec::new();

    for file in HelpAssets::iter() {
        if !file.ends_with(".md") {
            continue;
        }

        let Some(content) = HelpAssets::get(file.as_ref()) else {
            continue;
        };

        let content = std::str::from_utf8(content.data.as_ref())
            .map_err(|error| {
                io::Error::new(io::ErrorKind::InvalidData, error)
            })?;

        if let Some(command) = parse_help_file(content) {
            commands.push(command);
        }
    }

    commands.sort_by(|a, b| a.command.cmp(&b.command));

    println!("Veyra CLI");
    println!();
    println!("{:<22} DESCRIPTION", "COMMAND");
    println!("{}", "─".repeat(70));

    for command in commands {
        println!("{:<22} {}", command.command, command.description);
    }

    Ok(())
}

fn parse_help_file(content: &str) -> Option<HelpCommand> {
    let mut command = None;
    let mut description = None;

    for line in content.lines() {
        let line = line.trim();

        if command.is_none() && line.starts_with("# ") {
            command = Some(line[2..].trim().to_string());
            continue;
        }

        if command.is_some() && description.is_none() && !line.is_empty() {
            description = Some(line.to_string());
        }

        if command.is_some() && description.is_some() {
            break;
        }
    }

    match (command, description) {
        (Some(command), Some(description)) => {
            Some(HelpCommand {
                command,
                description,
            })
        }
        _ => None,
    }
}