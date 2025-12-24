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
  let result = case args.part {
    2 -> solve_2(processed_lines)
    _ -> solve(processed_lines)
  }
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

fn solve_2(puzzle_input: #(List(#(Int, Int)), List(Int))) -> Int {
  let #(ranges, _) = puzzle_input
  let collapsed_ranges = fold_the_ranges(ranges)
  list.fold(collapsed_ranges, 0, fn(count, range) {
    let #(min, max) = range
    count + max - min + 1
  })
}

fn fold_the_ranges(ranges: List(#(Int, Int))) -> List(#(Int, Int)) {
  let new_ranges =
    list.fold(ranges, [], fn(acc, focused_range) {
      let #(focused_min_range, focused_max_range) = focused_range
      let #(merged_intersections, did_the_merge) =
        list.fold(acc, #([], False), fn(int_acc, compare_range) {
          let #(merge_list, did_merge) = int_acc
          let #(compare_min_range, compare_max_range) = compare_range
          case compare_range == focused_range {
            False ->
              case
                focused_min_range <= compare_max_range
                && focused_min_range >= compare_min_range
              {
                True ->
                  case focused_max_range > compare_max_range {
                    True -> #(
                      list.append(merge_list, [
                        #(compare_min_range, focused_max_range),
                      ]),
                      True,
                    )
                    False -> #(
                      list.append(merge_list, [
                        #(compare_min_range, compare_max_range),
                      ]),
                      True,
                    )
                  }
                False -> {
                  case
                    compare_min_range <= focused_max_range
                    && compare_min_range >= focused_min_range
                  {
                    True ->
                      case focused_max_range > compare_max_range {
                        True -> #(
                          list.append(merge_list, [
                            #(focused_min_range, focused_max_range),
                          ]),
                          True,
                        )
                        False -> #(
                          list.append(merge_list, [
                            #(focused_min_range, compare_max_range),
                          ]),
                          True,
                        )
                      }
                    False -> #(
                      list.append(merge_list, [compare_range]),
                      did_merge,
                    )
                  }
                }
              }
            True -> #(merge_list, did_merge)
          }
        })
      case did_the_merge {
        False -> list.append(merged_intersections, [focused_range])
        _ -> merged_intersections
      }
    })
  case ranges == new_ranges {
    True -> new_ranges
    False -> fold_the_ranges(new_ranges)
  }
}
