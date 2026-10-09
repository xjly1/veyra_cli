use std::io;

use crate::commands;
use crate::parser::Command;

pub fn execute(command: Command) -> io::Result<()> {
    match command {
        Command::Version => {
            commands::version::run();
            Ok(())
        }

        Command::Tree { save, files } => {
            commands::tree::run(save, files)
        }

        Command::Help => commands::help::run(),
    }
}