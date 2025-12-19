import gleam/int
import gleam/list
import gleam/string
import simplifile as file
import utils/argy

pub fn main() -> Nil {
  let args = argy.parse_args()
  let path = args.input_file
  let assert Ok(contents) = file.read(from: path)
  let parts = string.split(contents, ",")
  let tuples = generate_tuples(parts, [])
  let result = solve_part1(tuples)
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

pub fn solve_part1(input: List(#(Int, Int))) -> Int {
  let res_list = inner_solve(input, [])
  accumulate_results(res_list, 0)
}

pub fn inner_solve(
  input: List(#(Int, Int)),
  range_result: List(Int),
) -> List(Int) {
  case input {
    [first, ..rest] -> {
      inner_solve(rest, list.append(range_result, process_range(first, [])))
    }
    [] -> range_result
  }
}

pub fn process_range(range: #(Int, Int), range_result: List(Int)) -> List(Int) {
  let #(curr, max) = range
  let next = curr + 1
  let str_curr = int.to_string(curr)
  let str_len = string.length(str_curr)
  let next_res = case str_len % 2 {
    0 -> {
      let half_len = str_len / 2
      let left_half_str = string.slice(str_curr, 0, half_len)
      let right_half_str = string.slice(str_curr, half_len, half_len)
      case left_half_str == right_half_str {
        True -> list.append(range_result, [curr])
        False -> range_result
      }
    }
    _ -> range_result
  }
  case next > max {
    True -> next_res
    False -> process_range(#(next, max), next_res)
  }
}

pub fn accumulate_results(result_list: List(Int), result: Int) -> Int {
  case result_list {
    [first, ..rest] -> accumulate_results(rest, result + first)
    [] -> result
  }
}
