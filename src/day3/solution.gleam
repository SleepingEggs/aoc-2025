import gleam/int
import gleam/string
import simplifile as file
import utils/argy

pub fn main() -> Nil {
  let args = argy.parse_args(root: "./src/day3/")
  let path = args.input_file
  let assert Ok(contents) = file.read(from: path)
  let lines = string.split(contents, "\n")
  let result = process_lines(lines, 0)
  echo result
  Nil
}

fn process_lines(lines: List(String), result: Int) -> Int {
  case lines {
    [line, ..rest] -> {
      process_lines(rest, result + process_single_line(line, #(0, 0)))
    }
    [] -> result
  }
}

fn process_single_line(line: String, highest_numbers: #(Int, Int)) -> Int {
  let line_length = string.length(line)
  case line_length {
    0 -> {
      let #(left, right) = highest_numbers
      int.add(left * 10, right)
    }
    _ -> {
      let first_char = string.slice(line, 0, 1)
      let assert Ok(converted_number) = int.parse(first_char)
      let #(left, right) = highest_numbers
      let new_numbers = case right > left {
        True -> #(right, converted_number)
        False -> {
          case converted_number > right {
            True -> #(left, converted_number)
            False -> #(left, right)
          }
        }
      }
      process_single_line(string.slice(line, 1, line_length), new_numbers)
    }
  }
}
