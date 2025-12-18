import argv

pub type Arguments {
  Arguments(input_file: String, part: Int, message: String)
}

pub fn parse_args() -> Arguments {
  parse_args_loop(argv.load().arguments, Arguments("./src/day1/input.txt", 1, ""))
}

fn parse_args_loop(cmd_args: List(String), output_args: Arguments) -> Arguments {
  case cmd_args {
    ["-i", input_file, ..rest] -> parse_args_loop(rest, Arguments(input_file: input_file, part: output_args.part, message: output_args.message))
    ["-p", ..rest] -> parse_args_loop(rest, Arguments(input_file: output_args.input_file, part: 2, message: output_args.message))
    [] -> output_args
    _ -> Arguments(input_file: output_args.input_file, part: output_args.part, message: "usage: gleam run src/day1/solution [-i <file_path>] [-p]")
  }
}