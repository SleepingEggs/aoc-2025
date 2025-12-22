import gleam/float
import gleam/int
import gleam/list
import gleam/string
import simplifile as file
import utils/argy

pub fn main() -> Nil {
  let args = argy.parse_args(root: "./src/day3/")
  let path = args.input_file
  let assert Ok(contents) = file.read(from: path)
  let lines = string.split(contents, "\n")
  let result = process_lines(lines, 0, args.part)
  echo result
  Nil
}

fn process_lines(lines: List(String), result: Int, part: Int) -> Int {
  case lines {
    [line, ..rest] -> {
      let assert Ok(line_result) = case part {
        1 -> Ok(process_single_line_part_1(line, #(0, 0)))
        2 -> Ok(process_single_line_part_2(line, []))
        _ -> Error("The part supplied is not supported")
      }
      process_lines(rest, result + line_result, part)
    }
    [] -> result
  }
}

fn process_single_line_part_1(line: String, highest_numbers: #(Int, Int)) -> Int {
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
      process_single_line_part_1(
        string.slice(line, 1, line_length),
        new_numbers,
      )
    }
  }
}

fn process_single_line_part_2(line: String, highest_numbers: List(Int)) -> Int {
  let line_length = string.length(line)
  case line_length {
    0 -> {
      sum_highest_numbers(highest_numbers, 0)
    }
    _ -> {
      let first_char = string.slice(line, 0, 1)
      let assert Ok(converted_number) = int.parse(first_char)
      let num_length = list.length(highest_numbers)
      let new_numbers = case num_length == 12 {
        True ->
          fit_number_into_list(highest_numbers, converted_number, False, [])
        False -> list.append(highest_numbers, [converted_number])
      }
      process_single_line_part_2(
        string.slice(line, 1, line_length),
        new_numbers,
      )
    }
  }
}

fn fit_number_into_list(
  numbers: List(Int),
  new_number: Int,
  dropped: Bool,
  result: List(Int),
) -> List(Int) {
  case numbers {
    [highest_order, second_highest, ..rest] -> {
      let next_list = list.append([second_highest], rest)
      case highest_order < second_highest && !dropped {
        True -> fit_number_into_list(next_list, new_number, True, result)
        False ->
          fit_number_into_list(
            next_list,
            new_number,
            dropped,
            list.append(result, [highest_order]),
          )
      }
    }
    [last] -> {
      case dropped {
        True ->
          fit_number_into_list(
            [],
            new_number,
            dropped,
            list.append(result, [last, new_number]),
          )
        False -> {
          case last > new_number {
            True ->
              fit_number_into_list(
                [],
                new_number,
                dropped,
                list.append(result, [last]),
              )
            False ->
              fit_number_into_list(
                [],
                new_number,
                dropped,
                list.append(result, [new_number]),
              )
          }
        }
      }
    }
    [] -> result
  }
}

fn sum_highest_numbers(numbers: List(Int), result: Int) -> Int {
  case numbers {
    [number, ..rest] -> {
      let power = list.length(rest)
      let assert Ok(power_result) = int.power(10, int.to_float(power))
      let num_result = number * float.round(power_result)
      sum_highest_numbers(rest, result + num_result)
    }
    [] -> result
  }
}
