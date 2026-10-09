use std::env;

#[derive(Debug)]
pub enum Command {
    Version,
    Tree {
        save: bool,
        files: bool,
    },
    Help,
}

pub fn filter() -> Command {
    let mut args = env::args();

    args.next();

    match args.next().as_deref() {
        Some("--version") | Some("-v") => Command::Version,

        Some("tree") => {
            let mut save = false;
            let mut files = false;

            for arg in args {
                match arg.as_str() {
                    "-s" => save = true,
                    "-f" => files = true,
                    _ => {}
                }
            }

            Command::Tree { save, files }
        }

        Some("help") => Command::Help,

        _ => Command::Help,
    }
}