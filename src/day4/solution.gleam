import gleam/list
import gleam/string
import simplifile as file
import utils/argy

pub fn main() -> Nil {
  let args = argy.parse_args(root: "./src/day3/")
  let path = args.input_file
  let assert Ok(contents) = file.read(from: path)
  let lines = string.split(contents, "\n")
  let grid = generate_grid(lines)
  let result = solve(grid, args.part)
  echo result
  Nil
}

fn generate_grid(lines: List(String)) -> List(List(Int)) {
  list.map(lines, fn(line) {
    let split_line = string.split(line, "")
    list.map(split_line, fn(new_line) {
      case new_line {
        "@" -> 1
        _ -> 0
      }
    })
  })
}

fn solve(grid: List(List(Int)), part: Int) -> Int {
  let indexed_grid =
    list.index_map(grid, fn(inner_list, index) {
      let indexed_list =
        list.index_map(inner_list, fn(val, ind) { #(ind, val) })
      #(index, indexed_list)
    })
  solve_loop(indexed_grid, part, 0)
}

fn solve_loop(
  grid: List(#(Int, List(#(Int, Int)))),
  part: Int,
  result: Int,
) -> Int {
  let loop_result =
    list.fold(grid, #(0, []), fn(acc, item) {
      let #(y_index, row) = item
      let #(y_count, y_list) = acc
      let #(x_result_count, x_result_list) =
        list.fold(row, #(0, []), fn(x_acc, x_item) {
          let #(x_index, paper) = x_item
          let #(x_count, x_list) = x_acc
          let mask_result = apply_mask(grid, #(x_index, y_index))
          case paper {
            1 -> {
              case mask_result {
                1 -> #(x_count + 1, list.append(x_list, [#(x_index, 0)]))
                _ -> #(x_count, list.append(x_list, [#(x_index, paper)]))
              }
            }
            _ -> #(x_count, list.append(x_list, [#(x_index, paper)]))
          }
        })
      #(
        y_count + x_result_count,
        list.append(y_list, [#(y_index, x_result_list)]),
      )
    })
  let #(loop_output, loop_grid) = loop_result
  case part {
    1 -> loop_output
    2 -> {
      case loop_output == 0 {
        True -> result
        False -> solve_loop(loop_grid, part, result + loop_output)
      }
    }
    _ -> 0
  }
}

fn apply_mask(
  indexed_grid: List(#(Int, List(#(Int, Int)))),
  coord: #(Int, Int),
) -> Int {
  let #(x, y) = coord
  let mask_coords = [
    #(x - 1, y - 1),
    #(x, y - 1),
    #(x + 1, y - 1),
    #(x - 1, y),
    #(x + 1, y),
    #(x - 1, y + 1),
    #(x, y + 1),
    #(x + 1, y + 1),
  ]
  let mask_result =
    list.fold(mask_coords, 0, fn(acc, i) {
      let #(mask_x, mask_y) = i
      let y_result = list.key_find(indexed_grid, mask_y)
      case y_result {
        Ok(ok_result) -> {
          let x_result = list.key_find(ok_result, mask_x)
          case x_result {
            Ok(x_ok_result) -> acc + x_ok_result
            Error(_err) -> acc
          }
        }
        Error(_err) -> acc
      }
    })
  case mask_result < 4 {
    True -> 1
    False -> 0
  }
}
