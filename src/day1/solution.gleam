import gleam/string
import gleam/list
import gleam/int
import simplifile as file
import utils/argy

pub fn main() -> Nil {
  let args = argy.parse_args()
  let path = args.input_file
  let assert Ok(contents) = file.read(from: path)
  let lines = string.split(contents, on: "\n")
  let numbers = convert_lines_to_numbers(lines, [])
  let result = case args.part {
    1 -> solve_part1(numbers, 50, 0)
    2 -> solve_part2(numbers, 50, 0)
    _ -> -1
  }
  echo result
  Nil
}

pub fn convert_lines_to_numbers(lines: List(String), numbers: List(Int)) -> List(Int) {
  case lines {
    [line, ..rest] -> convert_lines_to_numbers(rest, list.append(numbers, [convert_line_to_num(line)]))
    [] -> numbers
  }
}

pub fn convert_line_to_num(line: String) -> Int {
  case line {
    "" -> 0
    actual_line -> {
      let first_char = string.slice(from: actual_line, at_index: 0, length: 1)
      let number_string = string.slice(from: actual_line, at_index: 1, length: 100)
      let modifier = case first_char {
        "L" -> -1
        "R" -> 1
        _ -> 0
      }
      let assert Ok(number) = int.parse(number_string)
      number * modifier
    }
  }
}

pub fn solve_part1(numbers: List(Int), tracker: Int, result: Int) -> Int {
  case numbers {
    [first, ..rest] -> {
      let new_track = int.add(100, tracker + first) % 100
      let counter = case new_track {
        0 -> 1
        _ -> 0
      }
      solve_part1(rest, new_track, result + counter)
    }
    [] -> result
  }
}

pub fn solve_part2(numbers: List(Int), tracker: Int, result: Int) -> Int {
  case numbers {
    [first, ..rest] -> {
      let new_track = tracker + first
      let did_pass_0 = case tracker {
        0 -> False
        _ -> new_track <= 0
      }
      let assert Ok(rotations) = int.divide(new_track, 100)
      let counter_rot = int.absolute_value(rotations)
      let counter = case did_pass_0 {
        True -> counter_rot + 1
        False -> counter_rot
      }
      let final_tracker = int.add(100, new_track % 100) % 100
      solve_part2(rest, final_tracker, result + counter)
    }
    [] -> result
  }
}
