// Veyra CLI
// Copyright (C) 2026 xjly1
// Licensed under GPL-3.0-only. See LICENSE.

mod commands;
mod executor;
mod parser;

fn main() {
    let command = parser::filter();

    if let Err(error) = executor::execute(command) {
        eprintln!("Error: {error}");
    }
}