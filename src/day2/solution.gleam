import gleam/int
import gleam/list
import gleam/string
import simplifile as file
import utils/argy

pub fn main() -> Nil {
  let args = argy.parse_args(root: "./src/day2/")
  let path = args.input_file
  let assert Ok(contents) = file.read(from: path)
  let parts = string.split(contents, ",")
  let tuples = generate_tuples(parts, [])
  let result = solve(tuples, args.part)
  echo result
  Nil
}

pub fn generate_tuples(
  input: List(String),
  output: List(#(Int, Int)),
) -> List(#(Int, Int)) {
  case input {
    [first, ..rest] -> {
      let split = string.split(first, "-")
      let assert Ok(tuple) = case split {
        [one, two] -> {
          let assert Ok(parsed_one) = int.parse(one)
          let assert Ok(parsed_two) = int.parse(two)
          Ok(#(parsed_one, parsed_two))
        }
        _ -> Error("The split did not contain exactly two elements")
      }
      generate_tuples(rest, list.append(output, [tuple]))
    }
    [] -> output
  }
}

pub fn solve(input: List(#(Int, Int)), part: Int) -> Int {
  let res_list = inner_solve(input, [], part)
  accumulate_results(res_list, 0)
}

pub fn inner_solve(
  input: List(#(Int, Int)),
  range_result: List(Int),
  part: Int,
) -> List(Int) {
  case input {
    [first, ..rest] -> {
      inner_solve(
        rest,
        list.append(range_result, process_range(first, [], part)),
        part,
      )
    }
    [] -> range_result
  }
}

pub fn process_range(
  range: #(Int, Int),
  range_result: List(Int),
  part: Int,
) -> List(Int) {
  let #(curr, max) = range
  let next = curr + 1
  let str_curr = int.to_string(curr)
  let str_len = string.length(str_curr)
  let is_invalid_id = case part {
    1 -> process_string_1(str_curr, str_len)
    2 -> process_string_2(str_curr, str_len)
    _ -> False
  }
  let next_res = case is_invalid_id {
    True -> {
      list.append(range_result, [curr])
    }
    False -> range_result
  }
  case next > max {
    True -> next_res
    False -> process_range(#(next, max), next_res, part)
  }
}

pub fn process_string_1(str_curr: String, str_len: Int) -> Bool {
  case str_len % 2 {
    0 -> {
      let half_len = str_len / 2
      let left_half_str = string.slice(str_curr, 0, half_len)
      let right_half_str = string.slice(str_curr, half_len, half_len)
      left_half_str == right_half_str
    }
    _ -> False
  }
}

pub fn process_string_2(str_curr: String, str_len: Int) -> Bool {
  loop_part_2(str_curr, str_len, 1)
}

pub fn loop_part_2(str_curr: String, str_len: Int, curr_len: Int) -> Bool {
  case curr_len > str_len / 2 {
    True -> False
    False -> {
      case str_len % str_len {
        0 -> {
          case check_parts(str_curr, curr_len) {
            True -> True
            False -> loop_part_2(str_curr, str_len, curr_len + 1)
          }
        }
        _ -> loop_part_2(str_curr, str_len, curr_len + 1)
      }
    }
  }
}

fn check_parts(str: String, len: Int) -> Bool {
  let part1 = string.slice(str, 0, len)
  let part2 = string.slice(str, len, len)
  case string.length(part2) {
    0 -> True
    _ -> {
      case part1 == part2 {
        True -> check_parts(string.slice(str, len, string.length(str)), len)
        False -> False
      }
    }
  }
}

pub fn accumulate_results(result_list: List(Int), result: Int) -> Int {
  case result_list {
    [first, ..rest] -> accumulate_results(rest, result + first)
    [] -> result
  }
}
