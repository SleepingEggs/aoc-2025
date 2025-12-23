import gleam/int
import gleam/list
import gleam/string
import simplifile as file
import utils/argy

pub fn main() -> Nil {
  let args = argy.parse_args(root: "./src/day5/")
  let path = args.input_file
  let assert Ok(contents) = file.read(from: path)
  let lines = string.split(contents, "\n")
  let processed_lines = process_lines(lines)
  let result = solve(processed_lines)
  echo result
  Nil
}

fn process_lines(lines: List(String)) -> #(List(#(Int, Int)), List(Int)) {
  let #(result_range, result_spoils, _) =
    list.fold(lines, #([], [], False), fn(acc, line) {
      let #(ranges, spoils, is_spoils_time) = acc
      case is_spoils_time {
        True -> {
          let assert Ok(parsed_line) = int.parse(line)
          #(ranges, list.append(spoils, [parsed_line]), True)
        }
        False -> {
          case string.is_empty(line) {
            True -> {
              #(ranges, spoils, True)
            }
            False -> {
              let range_split = string.split(line, "-")
              let assert Ok(range_tuple) = case range_split {
                [left, right] -> {
                  let assert Ok(parsed_left) = int.parse(left)
                  let assert Ok(parsed_right) = int.parse(right)
                  Ok(#(parsed_left, parsed_right))
                }
                _ -> Error("oooops")
              }
              #(list.append(ranges, [range_tuple]), spoils, False)
            }
          }
        }
      }
    })
  #(result_range, result_spoils)
}

fn solve(puzzle_input: #(List(#(Int, Int)), List(Int))) -> Int {
  let #(ranges, spoils) = puzzle_input
  list.fold(spoils, 0, fn(acc, spoil) {
    case
      list.any(ranges, fn(range) {
        let #(min_range, max_range) = range
        spoil >= min_range && spoil <= max_range
      })
    {
      True -> acc + 1
      False -> acc
    }
  })
}
